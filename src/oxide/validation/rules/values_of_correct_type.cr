# Validation: Values of Correct Type
# https://spec.graphql.org/September2025/#sec-Values-of-Correct-Type
#
# Literal values must be compatible with the type expected in the position they are found
# as per the coercion rules defined in the Type System chapter.
#
# Formal Specification:
# - For each literal Input Value value in the document:
#   - Let type be the type expected in the position value is found.
#   - value must be coercible to type (with the assumption that any variableUsage
#     nested within value will represent a runtime value valid for usage in its position).

module Oxide
  module Validation
    class ValuesOfCorrectType < Rule
      def enter(node : Oxide::Language::Nodes::StringValue, context)
        validate_value(node, context, "String")
      end

      def enter(node : Oxide::Language::Nodes::IntValue, context)
        validate_value(node, context, "Int")
      end

      def enter(node : Oxide::Language::Nodes::FloatValue, context)
        validate_value(node, context, "Float")
      end

      def enter(node : Oxide::Language::Nodes::BooleanValue, context)
        validate_value(node, context, "Boolean")
      end

      def enter(node : Oxide::Language::Nodes::EnumValue, context)
        validate_enum_value(node, context)
      end

      def enter(node : Oxide::Language::Nodes::ListValue, context)
        # List values are validated by checking their items against the item type
        # This happens recursively as we visit each item
      end

      def enter(node : Oxide::Language::Nodes::ObjectValue, context)
        # Object values are validated by checking their fields
        # This happens as we visit each field
      end

      def enter(node : Oxide::Language::Nodes::NullValue, context)
        validate_null_value(node, context)
      end

      private def validate_value(node, context, value_type_name)
        expected_type = context.input_type
        return if expected_type.nil?

        # Unwrap non-null if present
        if expected_type.is_a?(Oxide::Types::NonNullType)
          expected_type = expected_type.of_type
        end

        # Get the actual type name
        actual_type_name = get_type_name(expected_type)
        return if actual_type_name.nil?

        # Check if the value type matches the expected type
        unless types_compatible?(value_type_name, actual_type_name)
          location = node.to_location
          error_message = build_error_message(node, expected_type, value_type_name, context)
          context.errors << ValidationError.new(error_message, [location])
        end
      end

      private def validate_enum_value(node, context)
        expected_type = context.input_type
        return if expected_type.nil?

        # Unwrap non-null if present
        if expected_type.is_a?(Oxide::Types::NonNullType)
          expected_type = expected_type.of_type
        end

        # Must be an enum type
        unless expected_type.is_a?(Oxide::Types::EnumType)
          location = node.to_location
          type_name = get_type_name(expected_type) || "Unknown"
          context.errors << ValidationError.new(
            "Enum value \"#{node.value}\" cannot be used for type \"#{type_name}\".",
            [location]
          )
          return
        end

        # Check if the enum value exists
        enum_type = expected_type.as(Oxide::Types::EnumType)
        unless enum_type.values.any? { |v| v.name == node.value }
          location = node.to_location
          message = "Value \"#{node.value}\" does not exist in \"#{enum_type.name}\" enum."
          
          # Add suggestions for similar enum values
          enum_value_names = enum_type.values.map(&.name)
          suggestions = Utils::SuggestionList.suggest(node.value, enum_value_names)
          if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
            message += suggestion_message
          end
          
          context.errors << ValidationError.new(message, [location])
        end
      end

      private def validate_null_value(node, context)
        expected_type = context.input_type
        return if expected_type.nil?

        # Null is not allowed for non-null types
        if expected_type.is_a?(Oxide::Types::NonNullType)
          location = node.to_location
          inner_type = expected_type.of_type
          type_name = get_full_type_name(expected_type)
          context.errors << ValidationError.new(
            "Null value cannot be used for non-null type \"#{type_name}\".",
            [location]
          )
        end
      end

      private def types_compatible?(value_type_name, expected_type_name)
        return true if value_type_name == expected_type_name
        
        # Int can coerce to Float
        return true if value_type_name == "Int" && expected_type_name == "Float"
        
        # ID can accept both String and Int
        return true if expected_type_name == "ID" && (value_type_name == "String" || value_type_name == "Int")
        
        false
      end

      private def get_type_name(type)
        case type
        when Oxide::Types::StringType
          "String"
        when Oxide::Types::IntType
          "Int"
        when Oxide::Types::FloatType
          "Float"
        when Oxide::Types::BooleanType
          "Boolean"
        when Oxide::Types::IdType
          "ID"
        when Oxide::Types::EnumType
          type.name
        when Oxide::Types::InputObjectType
          type.name
        when Oxide::Types::ListType
          "List"
        when Oxide::Types::NonNullType
          get_type_name(type.of_type)
        else
          nil
        end
      end

      private def get_full_type_name(type)
        case type
        when Oxide::Types::NonNullType
          "#{get_full_type_name(type.of_type)}!"
        when Oxide::Types::ListType
          "[#{get_full_type_name(type.of_type)}]"
        else
          get_type_name(type) || "Unknown"
        end
      end

      private def build_error_message(node, expected_type, value_type_name, context)
        type_name = get_full_type_name(expected_type)
        value_repr = case node
        when Oxide::Language::Nodes::StringValue
          "\"#{node.value}\""
        when Oxide::Language::Nodes::IntValue, Oxide::Language::Nodes::FloatValue
          node.value.to_s
        when Oxide::Language::Nodes::BooleanValue
          node.value ? "true" : "false"
        when Oxide::Language::Nodes::EnumValue
          node.value
        else
          node.print
        end

        # Check if we're in an ObjectField (input object field)
        if object_field_name = context.object_field_name
          # We're inside an input object field
          # The stack is: [..., ObjectType, FieldType]
          # So -2 is the parent object type
          parent_input_type = context.input_type_stack[-2]? if context.input_type_stack.size >= 2
          if parent_input_type
            # Unwrap NonNull if present
            unwrapped = parent_input_type
            while unwrapped.is_a?(Oxide::Types::NonNullType)
              unwrapped = unwrapped.of_type
            end
            parent_type_name = get_type_name(unwrapped)
            "Argument \"#{object_field_name}\" on InputObject \"#{parent_type_name}\" has an invalid value (#{value_repr}). Expected type \"#{type_name}\"."
          else
            "Field \"#{object_field_name}\" has an invalid value (#{value_repr}). Expected type \"#{type_name}\"."
          end
        elsif argument = context.argument
          # We're in a field argument
          arg_name = context.argument_name
          if field_def = context.field_definition
            field_name, _field = field_def
            "Argument \"#{arg_name}\" on Field \"#{field_name}\" has an invalid value (#{value_repr}). Expected type \"#{type_name}\"."
          else
            "Argument \"#{arg_name}\" has an invalid value (#{value_repr}). Expected type \"#{type_name}\"."
          end
        else
          "Value has an invalid type. Expected \"#{type_name}\", got \"#{value_type_name}\"."
        end
      end
    end
  end
end