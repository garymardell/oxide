require "json"

require "../query"
require "../schema"
require "../introspection_system"
require "../introspection/*"
require "./resolution_info"

module Graphene
  module Execution
    class Runtime
      class InputCoercionError < Exception
      end

      class FieldError < Exception
      end

      class NullError < FieldError
      end

      alias IntermediateType = SerializedOutput | Proc(IntermediateType) | Array(IntermediateType) | Hash(String, IntermediateType)

      getter schema : Graphene::Schema
      getter query : Graphene::Query
      getter initial_value : Resolvable?

      delegate document, to: query
      delegate context, to: query
      delegate directives, to: schema

      private property current_path : Array(String)
      private property current_object : Graphene::Types::ObjectType?
      private property current_field : Graphene::Language::Nodes::Field?

      private property errors : Set(String)

      def initialize(@schema : Graphene::Schema, @query : Graphene::Query, @initial_value : Resolvable? = nil)
        @current_path = [] of String
        @errors = Set(String).new
      end

      def execute
        definitions = document.definitions.select(type: Graphene::Language::Nodes::OperationDefinition)

        operation = get_operation(definitions, query.operation_name)

        coerced_variable_values = coerce_variable_values(schema, operation, @query.variables)

        data = case operation.operation_type
        when "query"
          execute_query(operation, schema, coerced_variable_values, initial_value)
        when "mutation"
          execute_mutation(operation, schema, coerced_variable_values, initial_value)
        end

        if errors.any?
          { "data" => data, "errors" => serialize_errors(errors) }
        else
          { "data" => data }
        end
      end

      private def get_operation(definitions, operation_name : Nil)
        if definitions.one?
          definitions.first
        else
          raise "operation definition not found"
        end
      end

      private def get_operation(definitions, operation_name : String)
        definition = definitions.find { |definition| definition.name == operation_name }

        if definition
          definition
        else
          raise "operation definition not found"
        end
      end

      private def execute_query(query, schema, coerced_variable_values, initial_value) : SerializedOutput
        if query_type = schema.query

          begin
            result = execute_selection_set(query.selection_set.not_nil!.selections, query_type, initial_value, coerced_variable_values)

            serialize(result)
          rescue FieldError
            nil
          end
        end
      end

      def serialize(result : IntermediateType) : SerializedOutput
        case result
        when Proc
          serialize(result.call)
        when Hash
          result.transform_values do |value|
            serialize(value).as(SerializedOutput)
          end
        when Array
          result.map do |value|
            serialize(value).as(SerializedOutput)
          end
        else
          result
        end
      end

      def serialize_errors(errors : Set(String))
        errors.map do |error|
          { "message" => error }
        end
      end

      private def execute_mutation(mutation, schema, coerced_variable_values, initial_value)
        if mutation_type = schema.mutation
          begin
            result = execute_selection_set(mutation.selection_set.not_nil!.selections, mutation_type, initial_value, coerced_variable_values)

            serialize(result)
          rescue FieldError
            nil
          end
        end
      end

      private def execute_selection_set(selection_set, object_type, object_value, variable_values) : Hash(String, IntermediateType)
        grouped_field_set = collect_fields(object_type, selection_set, variable_values, nil)

        partial_results = grouped_field_set.each_with_object({} of String => IntermediateType) do |(key, fields), memo|
          field_name = fields.first.name

          if field = get_field(object_type, field_name)
            field_type = field.type

            memo[key] = execute_field(object_type, object_value, field.type, fields, variable_values).as(IntermediateType)
          else
            raise "error getting field #{field_name}"
          end
        end
      end

      private def get_field(object_type, field_name)
        if schema.query == object_type && field_name == "__schema"
          Graphene::Field.new(type: Graphene::Introspection::SchemaType)
        elsif field_name == "__typename"
          Graphene::Field.new(type: Graphene::Types::StringType.new)
        else
          get_field_from_object_type(object_type, field_name)
        end
      end

      private def get_field_from_object_type(object_type, field_name)
        if field = object_type.fields[field_name]?
          return field
        end

        object_type.interfaces.each do |interface_type|
          if field = interface_type.fields[field_name]?
            return field
          end
        end

        nil
      end

      private def execute_field(object_type, object_value, field_type, fields, variable_values) : IntermediateType
        field = fields.first
        field_name = field.name

        argument_definitions = if schema_field = object_type.fields[field_name]?
          schema_field.arguments
        else
          {} of String => Graphene::Argument
        end

        argument_values = coerce_argument_values(argument_definitions, field.arguments, variable_values)

        if field_name == "__typename"
          return object_type.name
        end

        resolver = case field_name
        when "__schema"
          Graphene::Introspection::RootResolver.new
        else
          case object_type.name
          when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
            Graphene::IntrospectionSystem.resolvers[object_type.name]
          else
            object_type.resolver || DefaultResolver.new
          end
        end

        resolution_info = ResolutionInfo.new(
          schema: schema,
          query: query,
          field: schema_field,
        )

        value = resolver.resolve(object_value.as(Resolvable?), field_name, argument_values, context, resolution_info)

        if value.is_a?(Lazy)
          Proc(IntermediateType).new {
            value.resolve

            @current_object = object_type
            @current_field = field

            complete_value(@current_path, field_type, fields, value.value, variable_values).as(IntermediateType)
          }
        else
          @current_object = object_type
          @current_field = field

          complete_value(@current_path, field_type, fields, value, variable_values).as(IntermediateType)
        end
      end


      private def complete_value(path : Array(String), field_type : Graphene::Types::ObjectType, fields, result, variable_values) : IntermediateType
        return nil if result.nil?

        object_type = field_type

        sub_selection_set = merge_selection_sets(fields)

        begin
          execute_selection_set(sub_selection_set, object_type, result, variable_values).as(IntermediateType)
        rescue FieldError
          nil
        end
      end

      # TODO: Merge into object above?
      private def complete_value(path : Array(String), field_type : Graphene::Types::UnionType, fields, result, variable_values)
        return nil if result.nil?

        object_type = resolve_abstract_type(field_type, result)

        sub_selection_set = merge_selection_sets(fields)

        execute_selection_set(sub_selection_set, object_type, result, variable_values)
      end

      private def complete_value(path : Array(String), field_type : Graphene::Types::InterfaceType, fields, result, variable_values)
        return nil if result.nil?

        object_type = resolve_abstract_type(field_type, result)

        sub_selection_set = merge_selection_sets(fields)

        execute_selection_set(sub_selection_set, object_type, result, variable_values)
      end

      private def complete_value(path : Array(String), field_type : Graphene::Types::ScalarType, fields, result, variable_values) : IntermediateType
        return nil if result.nil?

        field_type.serialize(result).as(IntermediateType)
      end


      # If a List type wraps a Non-Null type, and one of the elements of that list resolves to null,
      # then the entire list must resolve to null. If the List type is also wrapped in a Non-Null,
      # the field error continues to propagate upwards.
      private def complete_value(path : Array(String), field_type : Graphene::Types::ListType, fields, result, variable_values) : IntermediateType
        return nil if result.nil?

        if result.is_a?(Array)
          inner_type = field_type.of_type

          partial_results = result.map do |result_item|
            if result_item.is_a?(Proc(IntermediateType))
              complete_value(path, inner_type, fields, result_item.call, variable_values).as(IntermediateType)
            else
              complete_value(path, inner_type, fields, result_item, variable_values).as(IntermediateType)
            end
          end

          partial_results.map do |value|
            if value.is_a?(Hash(String, IntermediateType))
              value.transform_values do |inner_value|
                if inner_value.is_a?(Proc(IntermediateType))
                  inner_value.call.as(IntermediateType)
                else
                  inner_value.as(IntermediateType)
                end
              end.as(IntermediateType)
            else
              value.as(IntermediateType)
            end
          end
        else
          raise FieldError.new("result is not a list")
        end
      end

      private def complete_value(path : Array(String), field_type : Graphene::Types::EnumType, fields, result, variable_values) : IntermediateType
        return nil if result.nil?

        if enum_value = field_type.values.find(&.value.==(result))
          enum_value.name.as(IntermediateType)
        else
          raise FieldError.new("`#{current_object.try(&.name)}.#{current_field.try(&.name)}` returned \"#{result}\" at ``, but this isn't a valid value for `#{field_type.name}`. Update the field or resolver to return one of the `#{field_type.name}`'s values instead.")
        end
      end

      private def complete_value(path : Array(String), field_type : Graphene::Types::NonNullType, fields, result, variable_values) : IntermediateType
        completed_result = complete_value(path, field_type.of_type, fields, result, variable_values)

        if completed_result.nil?
          field = fields.first

          errors << "Cannot return null for non-nullable field #{current_object.try(&.name)}.#{current_field.try(&.name)}"

          raise FieldError.new
        else
          completed_result.as(IntermediateType)
        end
      end

      private def complete_value(path : Array(String), field_type : Graphene::Types::LateBoundType, fields, result, variable_values) : IntermediateType
        unwrapped_type = get_type(field_type.typename)

        complete_value(path, unwrapped_type, fields, result, variable_values)
      end

      private def complete_value(path : Array(String), field_type, fields, result, variable_values) : IntermediateType
        raise "should not be reached"
      end

      private def get_type(typename)
        case typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
          IntrospectionSystem.types[typename]
        else
          schema.get_type(typename)
        end
      end

      private def get_type_from_ast(ast)
        schema.get_type_from_ast(ast)
      end

      private def collect_fields(object_type, selection_set, variable_values, visited_fragments)
        grouped_fields = {} of String => Array(Graphene::Language::Nodes::Field)
        visited_fragments ||= [] of String

        selection_set.each do |selection|
          if selection.responds_to?(:directives) && selection.directives.any?
            next if selection.directives.any? do |directive|
              schema_directive = directives.find(&.name.===(directive.name))

              if schema_directive
                directive_arguments = coerce_argument_values(schema_directive.arguments, directive.arguments, variable_values)

                !schema_directive.include?(object_type, nil, directive_arguments)
              else
                false
              end
            end
          end

          case selection
          when Graphene::Language::Nodes::Field
            response_key = selection.alias || selection.name

            grouped_fields[response_key] ||= [] of Graphene::Language::Nodes::Field
            grouped_fields[response_key] << selection
          when Graphene::Language::Nodes::FragmentSpread
            fragment_spread_name = selection.name

            next if visited_fragments.includes?(fragment_spread_name)

            visited_fragments << fragment_spread_name

            fragments = document.definitions.select(type: Graphene::Language::Nodes::FragmentDefinition)

            next unless fragment = fragments.find(&.name.===(fragment_spread_name))

            fragment_type = get_type(fragment.type_condition.not_nil!.name)

            next unless does_fragment_type_apply(object_type, fragment_type)

            fragment_selection_set = fragment.selection_set.not_nil!.selections
            fragment_grouped_field_set = collect_fields(object_type, fragment_selection_set, variable_values, visited_fragments)
            fragment_grouped_field_set.each do |response_key, fields|
              grouped_fields[response_key] ||= [] of Graphene::Language::Nodes::Field
              grouped_fields[response_key].concat(fields)
            end
          when Graphene::Language::Nodes::InlineFragment
            fragment_type = schema.get_type(selection.type_condition.not_nil!.name)

            next if !fragment_type.nil? && !does_fragment_type_apply(object_type, fragment_type)

            fragment_selection_set = selection.selection_set.not_nil!.selections
            fragment_grouped_field_set = collect_fields(object_type, fragment_selection_set, variable_values, visited_fragments)
            fragment_grouped_field_set.each do |response_key, fields|
              grouped_fields[response_key] ||= [] of Graphene::Language::Nodes::Field
              grouped_fields[response_key].concat(fields)
            end
          end
        end

        grouped_fields
      end

      private def merge_selection_sets(fields)
        selection_set = [] of Graphene::Language::Nodes::Selection

        fields.each do |field|
          next if field.selection_set.nil?

          selection_set.concat field.selection_set.not_nil!.selections
        end

        selection_set
      end

      private def coerce_argument_values(argument_definitions, arguments, variable_values)
        coerced_values = {} of String => SerializedOutput

        argument_values = arguments.each_with_object({} of String => Graphene::Language::Nodes::Value?) do |argument, memo|
          memo[argument.name] = argument.value
        end

        argument_definitions.each do |argument|
          argument_name, argument_definition = argument
          argument_type = argument_definition.type

          has_value = argument_values.has_key?(argument_name)

          argument_value = argument_values.fetch(argument_name, nil)

          value = if argument_value.is_a?(Graphene::Language::Nodes::Variable)
            variable = argument_value.as(Graphene::Language::Nodes::Variable)
            variable_name = variable.name

            unless variable_values.nil?
              variable_value = variable_values.not_nil!.fetch(variable_name, nil)

              has_value = !variable_value.nil?

              variable_value
            else
              nil
            end
          else
            argument_value.try &.value
          end

          if !has_value && argument_definition.has_default_value?
            # TODO: Something wrong with this conversion?
            coerced_values[argument_name] = argument_definition.default_value.not_nil!.as(SerializedOutput)
          elsif argument_type.is_a?(Graphene::Types::NonNullType) && (!has_value || value.nil?)
            raise "non nullable argument has null value"
          elsif has_value
            if value.nil?
              coerced_values[argument_name] = nil
            elsif argument_value.is_a?(Graphene::Language::Nodes::Variable)
              coerced_values[argument_name] = if value.is_a?(Hash)
                value.as(Hash(String, CoercedInput)).transform_values { |value| value.as(SerializedOutput) }
              else
                coerced_values[argument_name] = value.as(SerializedOutput)
              end
            else
              coerced_value = argument_type.coerce(value)
              coerced_values[argument_name] = coerced_value.as(SerializedOutput)
            end
          end
        end

        coerced_values
      end

      private def coerce_variable_values(schema, operation, variable_values)
        coerced_variables = {} of String => CoercedInput # TODO: Type may change

        variable_definitions = operation.variable_definitions
        variable_definitions.each do |variable_definition|
          variable_name = variable_definition.variable.not_nil!.name

          variable_type = @schema.get_type_from_ast(variable_definition.type)

          # TODO: Assert IsInputType
          default_value = variable_definition.default_value

          has_value = variable_values.has_key?(variable_name)
          value = variable_values.fetch(variable_name, nil)

          if !has_value && !variable_definition.default_value.nil?
            coerced_variables[variable_name] = variable_definition.default_value.not_nil!.value.as(CoercedInput)
          elsif variable_type.is_a?(Graphene::Language::Nodes::NonNullType) && (!has_value || value.nil?)
            raise "Variable is marked as non null but received a null value"
          elsif has_value
            if value.nil?
              coerced_variables[variable_name] = nil
            else
              # TODO: Support coercion for all types
              coerced_value = if variable_type.responds_to?(:coerce)
                variable_type.coerce(value)
              else
                value
              end

              case coerced_value
              when JSON::Any
                coerced_variables[variable_name] = coerced_value.raw.as(CoercedInput)
              else
                coerced_variables[variable_name] = coerced_value.as(CoercedInput)
              end
            end
          end
        end

        coerced_variables
      end

      private def does_fragment_type_apply(object_type, fragment_type)
        case fragment_type
        when Graphene::Types::ObjectType
          object_type.name == fragment_type.name
        when Graphene::Types::UnionType
          fragment_type.possible_types.includes?(object_type)
        else
          object_type.interfaces.includes?(fragment_type)
        end
      end

      private def resolve_abstract_type(field_type, result)
        # if resolved_type = type_resolvers[field_type.name].resolve_type(result, context)
        if resolved_type = field_type.type_resolver.resolve_type(result, context)
          resolved_type
        else
          raise "abstract type could not be resolved"
        end
      end
    end
  end
end