require "json"
require "promise"

module Graphql
  module Execution
    class Interpreter
      class Runtime
        alias ReturnType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ReturnType) | Hash(String, ReturnType)

        property schema : Graphql::Schema
        property query : Graphql::Language::Nodes::Document
        property response

        def initialize(@schema, @query) # Operation name from url
          @response = {} of String => JSON::Any
        end

        def execute
          definitions = query.definitions.select(type: Graphql::Language::Nodes::OperationDefinition)

          operation = if definitions.size > 1
            definitions.first # Find appropriate operation
          else
            definitions.first
          end

          case operation.operation_type
          when "query"
            execute_query(operation, schema)
          when "mutation"
            execute_mutation(operation, schema)
          end
        end

        def execute_query(query, schema)
          if query_type = schema.query
            execute_selection_set(query.selections, query_type, nil)
          end
        end

        def execute_mutation(mutation, schema)
          if mutation_type = schema.mutation
            execute_selection_set(mutation.selections, mutation_type, nil)
          end
        end

        def execute_selection_set(selection_set, object_type, object_value) # TODO: variable_values
          grouped_field_set = collect_fields(object_type, selection_set, nil, nil)
          
          lazy_results = grouped_field_set.map do |response_key, fields|
            field_name = fields.first.name

            if field = object_type.get_field(field_name)
              field_type = field.type

              {response_key, field_type, fields, execute_field(object_type, object_value, field_type, fields)}
            end
          end

          lazy_results.each_with_object({} of String => ReturnType) do |tuple, memo|
            next unless tuple

            value = tuple[3]

            ret = if value.is_a?(Promise::DeferredPromise)
              value.get
            else
              value
            end

            memo[tuple[0]] = complete_value(tuple[1], tuple[2], ret)
          end
        end

        def execute_field(object_type, object_value, field_type, fields)
          field = fields.first
          field_name = field.name

          argument_values = coerce_argument_values(object_type, field) # TODO: variable_values

          resolved_value = object_type.resolver.try &.resolve(object_value, field_name, argument_values)
        end

        def complete_value(field_type : Graphql::Schema::Object, fields, result)
          field = fields.first

          object_type = field_type
          
          execute_selection_set(field.selections, object_type, result)
        end

        def complete_value(field_type : Graphql::Schema::Scalar, fields, result : ReturnType)
          result.as(ReturnType)
        end

        def complete_value(field_type : Graphql::Schema::List, fields, result)
          if result.is_a?(Array)
            inner_type = field_type.of_type

            items = [] of ReturnType

            result.each do |result_item|
              items << complete_value(inner_type, fields, result_item)
            end

            items
          else
            raise "result is not a list"
          end
        end

        def complete_value(field_type : Graphql::Schema::Enum, fields, result : ReturnType)
          if enum_value = field_type.values.find(&.value.==(result))
            enum_value.name
          else
            nil.as(ReturnType)
          end
        end

        def complete_value(field_type : Graphql::Schema::NonNull, fields, result)
          if result.nil?
            raise "null issues"
          else
            complete_value(field_type.of_type, fields, result)
          end
        end

        def complete_value(field_type, fields, result)
          raise "should not be reached"
        end

        def collect_fields(object_type, selection_set, variable_values, visited_fragments) # TODO: variable_values, visited_fragments
          grouped_fields = {} of String => Array(Graphql::Language::Nodes::Field)
          visited_fragments = [] of String

          selection_set.each do |selection|
            # TODO: @skip directive
            # TODO: @include directive
            case selection
            when Graphql::Language::Nodes::Field
              response_key = selection.name

              grouped_fields[response_key] ||= [] of Graphql::Language::Nodes::Field
              grouped_fields[response_key] << selection
            when Graphql::Language::Nodes::FragmentSpread
              fragment_spread_name = selection.name

              next if visited_fragments.includes?(fragment_spread_name)

              visited_fragments << fragment_spread_name

              fragments = query.definitions.select(type: Graphql::Language::Nodes::FragmentDefinition)

              next unless fragment = fragments.find(&.name.===(fragment_spread_name))
              
              fragment_type = fragment.type_condition

              next unless does_fragment_type_apply(object_type, fragment_type)

              fragment_selection_set = fragment.selections
              fragment_grouped_field_set = collect_fields(object_type, fragment_selection_set, nil, visited_fragments)
              fragment_grouped_field_set.each do |response_key, fields|
                grouped_fields[response_key] ||= [] of Graphql::Language::Nodes::Field
                grouped_fields[response_key].concat(fields)
              end
            end
            # TODO: inline fragment
          end

          grouped_fields
        end

        def coerce_argument_values(object_type, field)
          coerced_values = {} of String => ReturnType
          argument_values = field.arguments.each_with_object({} of String => Graphql::Language::Nodes::Value) do |argument, memo|
            memo[argument.name] = argument.value
          end

          field_name = field.name
          if schema_field = object_type.get_field(field_name)
            argument_definitions = schema_field.arguments
            argument_definitions.each do |argument_definition|
              argument_name = argument_definition.name
              argument_type = argument_definition.type

              has_value = argument_values.has_key?(argument_name)

              argument_value = argument_values.fetch(argument_name, nil)
              
              is_variable = false # TODO: Implement argument variables
              value = if is_variable
                # Let variableName be the name of argumentValue.
                # Let hasValue be true if variableValues provides a value for the name variableName.
                # Let value be the value provided in variableValues for the name variableName.
                nil
              else
                argument_value
              end

              if !has_value && argument_definition.has_default_value?
                coerced_values[argument_name] = argument_definition.default_value.as(ReturnType)
              elsif argument_type.is_a?(Graphql::Schema::NonNull) && (!has_value || value.nil?)
                raise "non nullable argument has null value"
              elsif has_value
                if value.nil?
                  coerced_values[argument_name] = nil
                elsif false #  if argumentValue is a Variable
                  # Add an entry to coercedValues named argumentName with the value value.
                else
                  # If value cannot be coerced according to the input coercion rules of variableType, throw a field error.
                  coerced_values[argument_name] = value.as(ReturnType)
                end
              end
            end
          end

          coerced_values
        end

        def does_fragment_type_apply(object_type, fragment_type) # TODO: Proper handling of fragment type
          object_type.name == fragment_type
        end
      end
    end
  end
end