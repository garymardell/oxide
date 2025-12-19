# Validation: Fragment Spread Target Defined
# https://spec.graphql.org/September2025/#sec-Fragment-spread-target-defined
#
# Named fragment spreads must refer to fragments defined within the document.
# It is a validation error if the target of a spread is not defined.
#
# Formal Specification:
# - For each named spread in the document:
#   - Let fragment be the target of the spread
#   - fragment must be defined in the document

module Oxide
  module Validation
    class FragmentSpreadTargetDefined < Rule
      def initialize
        @defined_fragments = Set(String).new
        @spread_fragments = [] of {String, Oxide::Language::Nodes::FragmentSpread}
      end

      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        @defined_fragments << node.name
      end

      def enter(node : Oxide::Language::Nodes::FragmentSpread, context)
        @spread_fragments << {node.name, node}
      end

      def leave(node : Oxide::Language::Nodes::Document, context)
        @spread_fragments.each do |fragment_name, spread_node|
          unless @defined_fragments.includes?(fragment_name)
            message = "Unknown fragment \"#{fragment_name}\"."
            
            # Add suggestions for similar fragment names
            suggestions = Utils::SuggestionList.suggest(fragment_name, @defined_fragments.to_a)
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
