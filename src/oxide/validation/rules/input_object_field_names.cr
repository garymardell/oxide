# For each Input Object Field inputField in the document:
# Let inputFieldName be the Name of inputField.
# Let inputFieldDefinition be the input field definition provided by the parent input object type named inputFieldName.
# inputFieldDefinition must exist.


module Oxide
  module Validation
    class InputObjectFieldNames < Rule
      def enter(node : Oxide::Language::Nodes::ObjectField, context)
        input_field_name = node.name

        # When we enter ObjectField, the context visitor has already pushed the field type
        # So we need to look at the parent type (at index -2)
        # But we want to check before that push happened, so let's look at the stack
        parent_input_type = if context.input_type_stack.size >= 2
          context.input_type_stack[-2]
        else
          context.input_type_stack[-1]
        end

        case input_type = parent_input_type
        when Oxide::Types::InputObjectType
          input_field_definition = input_type.input_fields[input_field_name]?

          if input_field_definition.nil?
            context.errors << ValidationError.new("InputObject '#{input_type.name}' doesn't accept argument '#{input_field_name}'")
          end
        end
      end
    end
  end
end