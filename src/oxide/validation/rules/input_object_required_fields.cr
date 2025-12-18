# Validation: Input Object Required Fields
# https://spec.graphql.org/September2025/#sec-Input-Object-Required-Fields
#
# Input object fields may be required. Much like a field may have required arguments,
# an input object may have required fields. An input field is required if it has a
# non-null type and does not have a default value. Otherwise, the input object field
# is optional.
#
# Formal Specification:
# - For each Input Object in the document:
#   - Let fields be the fields provided by that Input Object.
#   - Let fieldDefinitions be the set of input field definitions of that Input Object.
#   - For each fieldDefinition in fieldDefinitions:
#     - Let type be the expected type of fieldDefinition.
#     - Let defaultValue be the default value of fieldDefinition.
#     - If type is Non-Null and defaultValue does not exist:
#       - Let fieldName be the name of fieldDefinition.
#       - Let field be the input field in fields named fieldName.
#       - field must exist.
#       - Let value be the value of field.
#       - value must not be the null literal.

module Oxide
  module Validation
    class InputObjectRequiredFields < Rule
      def enter(node : Oxide::Language::Nodes::ObjectValue, context)
        input_type = context.input_type
        
        # Get the named type (unwrap lists and non-nulls)
        object_type = named_type(input_type)
        
        # Only validate if we have an input object type
        return unless object_type.is_a?(Oxide::Types::InputObjectType)
        
        # Get the fields provided in the input object
        provided_fields = node.fields.map(&.name).to_set
        
        # Check each field definition
        object_type.input_fields.each do |field_name, field_def|
          # Check if field is required (non-null type and no default value)
          if field_def.type.is_a?(Oxide::Types::NonNullType) && field_def.default_value.nil?
            unless provided_fields.includes?(field_name)
              location = node.to_location
              context.errors << ValidationError.new(
                "Input field '#{object_type.name}.#{field_name}' of type '#{field_def.type}' is required, but it was not provided.",
                [location]
              )
            else
              # Check if the provided field value is not null
              provided_field = node.fields.find { |f| f.name == field_name }
              if provided_field && provided_field.value.is_a?(Oxide::Language::Nodes::NullValue)
                location = provided_field.to_location
                context.errors << ValidationError.new(
                  "Input field '#{object_type.name}.#{field_name}' of type '#{field_def.type}' cannot be null.",
                  [location]
                )
              end
            end
          end
        end
      end
      
      private def named_type(type)
        case type
        when Oxide::Types::ListType
          named_type(type.of_type)
        when Oxide::Types::NonNullType
          named_type(type.of_type)
        else
          type
        end
      end
    end
  end
end