# For each argument in the document
# Let argumentName be the Name of argument.
# Let argumentDefinition be the argument definition provided by the parent field or definition named argumentName.
# argumentDefinition must exist.
module Oxide
  module Validation
    class ArgumentNames < Rule
      def enter(node : Oxide::Language::Nodes::Argument, context)
        definition = context.argument
        field_definition = context.field_definition
        parent_type = context.parent_type

        unless definition
          if directive = context.directive
            message = "Unknown argument \"#{node.name}\" on directive \"@#{directive.name}\"."
            
            # Add suggestions for similar argument names
            arg_names = directive.arguments.keys
            suggestions = Utils::SuggestionList.suggest(node.name, arg_names)
            if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
              message += suggestion_message
            end
            
            context.errors << ValidationError.new(message)
          elsif field_definition && parent_type
            field_name, field = field_definition

            type_name = if parent_type.responds_to?(:name)
              parent_type.name
            end

            message = if type_name
              "Unknown argument \"#{node.name}\" on field \"#{type_name}.#{field_name}\"."
            else
              "Unknown argument \"#{node.name}\" on field \"#{field_name}\"."
            end
            
            # Add suggestions for similar argument names
            arg_names = field.arguments.keys
            suggestions = Utils::SuggestionList.suggest(node.name, arg_names)
            if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
              message += suggestion_message
            end
            
            context.errors << ValidationError.new(message, [node.to_location])
          end
        end
      end
    end
  end
end