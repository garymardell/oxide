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

        coerced_variable_values = coerce_variable_values(schema, operation, @query.variables)

        case operation.operation_type
        when "query"
          execute_query(operation, schema, coerced_variable_values)
        when "mutation"
          execute_mutation(operation, schema, coerced_variable_values)
        end
      end

      private def execute_query(query, schema, coerced_variable_values)
        if query_type = schema.query
          execute_selection_set(query.selections, query_type, nil, coerced_variable_values)
        end
      end

      private def execute_mutation(mutation, schema, coerced_variable_values)
        if mutation_type = schema.mutation
          execute_selection_set(mutation.selections, mutation_type, nil, nil)
        end
      end

      private def execute_selection_set(selection_set, object_type, object_value, variable_values)
        grouped_field_set = collect_fields(object_type, selection_set, variable_values, nil)

        grouped_field_set.each_with_object({} of String => ReturnType) do |(response_key, fields), memo|
          field_name = fields.first.name

          if field = get_field(object_type, field_name)
            field_type = field.type

            memo[response_key] = execute_field(object_type, object_value, field.type, fields, variable_values)
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

      private def execute_field(object_type, object_value, field_type, fields, variable_values)
        field = fields.first
        field_name = field.name

        argument_values = coerce_argument_values(object_type, field, variable_values)

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

        execute_selection_set(field.selections, object_type, result, nil)
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
          # schema.types[field_type.typename]
        end

        complete_value(unwrapped_type, fields, result)
      end

      private def complete_value(field_type, fields, result)
        raise "should not be reached"
      end

      private def collect_fields(object_type, selection_set, variable_values, visited_fragments) # TODO: variable_values, visited_fragments
        grouped_fields = {} of String => Array(Graphql::Language::Nodes::Field)
        visited_fragments ||= [] of String

        selection_set.each do |selection|
          # TODO: @skip directive, uses variable_values
          # TODO: @include directive, uses variable_values
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
            fragment_grouped_field_set = collect_fields(object_type, fragment_selection_set, variable_values, visited_fragments)
            fragment_grouped_field_set.each do |response_key, fields|
              grouped_fields[response_key] ||= [] of Graphql::Language::Nodes::Field
              grouped_fields[response_key].concat(fields)
            end
          end
          # TODO: inline fragment
        end

        grouped_fields
      end

      private def coerce_argument_values(object_type, field, variable_values)
        coerced_values = {} of String => ReturnType
        argument_values = field.arguments.each_with_object({} of String => Graphql::Language::Nodes::ValueType) do |argument, memo|
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

            value = if argument_value.is_a?(Graphql::Language::Nodes::Variable)
              variable = argument_value.as(Graphql::Language::Nodes::Variable)
              variable_name = variable.name

              unless variable_values.nil?
                variable_value = variable_values.not_nil!.fetch(variable_name, nil)

                has_value = !variable_value.nil?

                variable_value
              else
                nil
              end
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
              elsif argument_value.is_a?(Graphql::Language::Nodes::Variable)
                coerced_values[argument_name] = value.as(ReturnType)
              else
                # If value cannot be coerced according to the input coercion rules of variableType, throw a field error.
                coerced_value = value.as(ReturnType)
                coerced_values[argument_name] = coerced_value
              end
            end
          end
        end

        coerced_values
      end

      private def coerce_variable_values(schema, operation, variable_values)
        coerced_variables = {} of String => JSON::Any::Type # TODO: Type may change

        variable_definitions = operation.variable_definitions
        variable_definitions.each do |variable_definition|
          variable_name = variable_definition.variable.name

          variable_type = @schema.get_type_from_ast(variable_definition.type)

          # TODO: Assert IsInputType
          default_value = variable_definition.default_value

          has_value = variable_values.has_key?(variable_name)
          value = variable_values.fetch(variable_name, nil)

          if !has_value && !variable_definition.default_value.nil?
            coerced_variables[variable_name] = variable_definition.default_value.not_nil!.value.as(JSON::Any::Type)
          elsif variable_type.is_a?(Graphql::Language::Nodes::NonNullType) && (!has_value || value.nil?)
            raise "Variable is marked as non null but received a null value"
          elsif has_value
            if value.nil?
              coerced_variables[variable_name] = nil.as(JSON::Any::Type)
            else
              # TODO: Support coercion for all types
              coerced_value = if variable_type.responds_to?(:coerce)
                variable_type.coerce(value)
              else
                value
              end

              coerced_variables[variable_name] = coerced_value.as(JSON::Any::Type)
            end
          end
        end

        coerced_variables
      end

      private def does_fragment_type_apply(object_type, fragment_type) # TODO: Proper handling of fragment type
        object_type.typename == fragment_type
      end
    end
  end
end