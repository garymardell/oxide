# Validation: Fragments Must Be Used
# https://spec.graphql.org/September2025/#sec-Fragments-Must-Be-Used
#
# Defined fragments must be used within a document.
#
# Formal Specification:
# - For each fragment defined in the document:
#   - fragment must be the target of at least one spread in the document

module Oxide
  module Validation
    class FragmentsMustBeUsed < Rule
      def initialize
        @defined_fragments = Set(String).new
        @used_fragments = Set(String).new
      end

      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        @defined_fragments << node.name
      end

      def enter(node : Oxide::Language::Nodes::FragmentSpread, context)
        @used_fragments << node.name
      end

      def leave(node : Oxide::Language::Nodes::Document, context)
        unused_fragments = @defined_fragments - @used_fragments
        
        unused_fragments.each do |fragment_name|
          context.errors << ValidationError.new(
            "Fragment '#{fragment_name}' is never used."
          )
        end
      end
    end
  end
end
