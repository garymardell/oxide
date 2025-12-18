# Validation: Fragment Name Uniqueness
# https://spec.graphql.org/September2025/#sec-Fragment-Name-Uniqueness
#
# Fragment definitions are referenced in fragment spreads by name. To avoid ambiguity,
# each fragment's name must be unique within a document.
#
# Formal Specification:
# - For each fragment definition fragment in the document:
#   - Let fragmentName be the name of fragment.
#   - Let fragments be all fragment definitions in the document named fragmentName.
#   - fragments must be a set of one.

module Oxide
  module Validation
    class FragmentNameUniqueness < Rule
      def initialize
        @fragment_names = {} of String => Array(Oxide::Language::Nodes::FragmentDefinition)
      end

      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        fragment_name = node.name

        if @fragment_names.has_key?(fragment_name)
          @fragment_names[fragment_name] << node
        else
          @fragment_names[fragment_name] = [node]
        end
      end

      def leave(node : Oxide::Language::Nodes::Document, context)
        @fragment_names.each do |name, fragments|
          if fragments.size > 1
            context.errors << ValidationError.new(
              "There can be only one fragment named '#{name}'."
            )
          end
        end
      end
    end
  end
end