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
            message = "Field \"#{input_field_name}\" is not defined by type \"#{input_type.name}\"."
            field_names = input_type.input_fields.keys
            suggestions = Utils::SuggestionList.suggest(input_field_name, field_names)
            if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
              message += suggestion_message
            end
            context.errors << ValidationError.new(message)
          end
        end
      end
    end
  end
end