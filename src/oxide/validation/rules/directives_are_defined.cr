module Oxide
  module Validation
    class DirectivesAreDefined < Rule
      def enter(node : Oxide::Language::Nodes::Directive, context)
        directive_name = node.name
        directive_definition = context.schema.directives.find { |directive| directive.name == directive_name }

        unless directive_definition
          message = "Unknown directive \"@#{directive_name}\"."
          
          # Add suggestions for similar directive names
          directive_names = context.schema.directives.map(&.name)
          suggestions = Utils::SuggestionList.suggest(directive_name, directive_names)
          if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
            message += suggestion_message
          end
          
          context.errors << ValidationError.new(message)
        end
      end
    end
  end
end
