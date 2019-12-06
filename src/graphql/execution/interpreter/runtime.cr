require "json"

module Graphql
  module Execution
    class Interpreter
      class Runtime
        alias ReturnType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ReturnType) | Hash(String, ReturnType)

        property schema : Graphql::Schema
        property query : Graphql::Language::Nodes::Document
        property response

        def initialize(@schema, @query)
          @response = {} of String => JSON::Any
        end

        def execute
          if query_object = schema.query
            root_operation = query.definitions.first # OperationDefinition(operation_type: "Query")

            execute_selection_set(root_operation.selections, query_object, nil)
          end
        end

        def execute_selection_set(selection_set, object_type, object_value) # TODO: variable_values
          result = Hash(String, ReturnType).new

          grouped_field_set = collect_fields(object_type, selection_set)

          grouped_field_set.each do |response_key, fields|
            field_name = fields.first.name

            if field = object_type.get_field(field_name)
              field_type = field.type

              result[response_key] =
                execute_field(object_type, object_value, field_type, fields)
            end
          end

          result.as(ReturnType)
        end

        def execute_field(object_type, object_value, field_type, fields)
          field = fields.first
          field_name = field.name

          resolved_value = object_type.resolver.try &.resolve(object_value, field_name)

          complete_value(field_type, field, resolved_value)
        end

        def complete_value(field_type : Graphql::Schema::Object, field, result)
          object_type = field_type

          execute_selection_set(field.selections, object_type, result)
        end

        def complete_value(field_type : Graphql::Schema::Scalar, field, result)
          result.as(ReturnType)
        end

        def collect_fields(object_type, selection_set) # TODO: variable_values, visited_fragments
          grouped_fields = {} of String => Array(Graphql::Language::Nodes::Field)

          selection_set.each do |selection|
            # TODO: @skip directive
            # TODO: @include directive
            case selection
            when Graphql::Language::Nodes::Field
              response_key = selection.name

              grouped_fields[response_key] ||= [] of Graphql::Language::Nodes::Field
              grouped_fields[response_key] << selection
            end
            # TODO: fragment spread
            # TODO: inline fragment
          end

          grouped_fields
        end
      end
    end
  end
end
