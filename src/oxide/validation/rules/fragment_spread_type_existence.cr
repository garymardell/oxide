# Validation: Fragment Spread Type Existence
# https://spec.graphql.org/September2025/#sec-Fragment-Spread-Type-Existence
#
# Fragments must be specified on types that exist in the schema. This applies for both
# named and inline fragments. If they are not defined in the schema, the fragment is invalid.
#
# Formal Specification:
# - For each named spread namedSpread in the document:
#   - Let fragment be the target of namedSpread.
#   - The target type of fragment must be defined in the schema.

module Oxide
  module Validation
    class FragmentSpreadTypeExistence < Rule
      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        return unless type_condition = node.type_condition

        type_name = type_condition.name
        
        unless context.schema.get_type(type_name)
          message = "Unknown type \"#{type_name}\"."
          
          # Add suggestions for similar type names
          type_names = context.schema.type_map.keys
          suggestions = Utils::SuggestionList.suggest(type_name, type_names)
          if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
            message += suggestion_message
          end
          
          context.errors << ValidationError.new(message)
        end
      end

      def enter(node : Oxide::Language::Nodes::InlineFragment, context)
        return unless type_condition = node.type_condition

        type_name = type_condition.name
        
        unless context.schema.get_type(type_name)
          message = "Unknown type \"#{type_name}\"."
          
          # Add suggestions for similar type names
          type_names = context.schema.type_map.keys
          suggestions = Utils::SuggestionList.suggest(type_name, type_names)
          if suggestion_message = Utils::SuggestionList.did_you_mean_message(suggestions)
            message += suggestion_message
          end
          
          context.errors << ValidationError.new(message)
        end
      end
    end
  end
end