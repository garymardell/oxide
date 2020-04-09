require "json"
require "promise"

require "../query"
require "../schema"
require "../introspection_system"
require "../introspection/*"

module Graphql
  module Execution
    class Runtime
      alias ReturnType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ReturnType) | Hash(String, ReturnType)

      getter schema : Graphql::Schema
      getter query : Graphql::Query

      delegate document, to: query

      private property response

      def initialize(@schema : Graphql::Schema, @query : Graphql::Query)
        @response = {} of String => JSON::Any
      end

      def execute
        definitions = document.definitions.select(type: Graphql::Language::Nodes::OperationDefinition)

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

      private def execute_query(query, schema)
        if query_type = schema.query
          execute_selection_set(query.selections, query_type, nil)
        end
      end

      private def execute_mutation(mutation, schema)
        if mutation_type = schema.mutation
          execute_selection_set(mutation.selections, mutation_type, nil)
        end
      end

      private def execute_selection_set(selection_set, object_type, object_value) # TODO: variable_values
        grouped_field_set = collect_fields(object_type, selection_set, nil, nil)

        grouped_field_set.each_with_object({} of String => ReturnType) do |(response_key, fields), memo|
          field_name = fields.first.name

          if field = get_field(object_type, field_name)
            field_type = field.type

            memo[response_key] = execute_field(object_type, object_value, field.type, fields)
          end
        end
      end

      private def get_field(object_type, field_name)
        if schema.query == object_type && field_name == "__schema"
          Graphql::Schema::Field.new(name: "__schema", type: Graphql::Introspection::SchemaType)
        elsif field_name == "__typename"
          Graphql::Schema::Field.new(name: "__typename", type: Graphql::Type::String.new)
        else
          object_type.get_field(field_name)
        end
      end

      private def execute_field(object_type, object_value, field_type, fields)
        field = fields.first
        field_name = field.name

        argument_values = coerce_argument_values(object_type, field) # TODO: variable_values

        if field_name == "__typename"
          object_type.typename
        elsif resolver = object_type.resolver
          resolver.schema = schema
          resolved_value = resolver.resolve(object_value, field_name, argument_values)

          complete_value(field_type, fields, resolved_value)
        end
      end

      private def complete_value(field_type : Graphql::Type::Object, fields, result)
        field = fields.first

        object_type = field_type

        execute_selection_set(field.selections, object_type, result)
      end

      private def complete_value(field_type : Graphql::Type::Scalar, fields, result : ReturnType)
        field_type.coerce(result).as(ReturnType)
      end

      private def complete_value(field_type : Graphql::Type::List, fields, result)
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

      private def complete_value(field_type : Graphql::Type::Enum, fields, result : ReturnType)
        if enum_value = field_type.values.find(&.value.==(result))
          enum_value.name
        else
          nil.as(ReturnType)
        end
      end

      private def complete_value(field_type : Graphql::Type::NonNull, fields, result)
        if result.nil?
          raise "expected field \"#{fields.first.name}\" of type #{field_type.of_type} to not be nil"
        else
          complete_value(field_type.of_type, fields, result)
        end
      end

      private def complete_value(field_type : Graphql::Type::LateBound, fields, result)
        unwrapped_type = case field_type.typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue"
          IntrospectionSystem.types[field_type.typename]
        else
          schema.types[field_type.typename]
        end

        complete_value(unwrapped_type, fields, result)
      end

      private def complete_value(field_type, fields, result)
        raise "should not be reached"
      end

      private def collect_fields(object_type, selection_set, variable_values, visited_fragments) # TODO: variable_values, visited_fragments
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

            fragments = document.definitions.select(type: Graphql::Language::Nodes::FragmentDefinition)

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

      private def coerce_argument_values(object_type, field)
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
            elsif argument_type.is_a?(Graphql::Type::NonNull) && (!has_value || value.nil?)
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

      private def does_fragment_type_apply(object_type, fragment_type) # TODO: Proper handling of fragment type
        object_type.typename == fragment_type
      end
    end
  end
end