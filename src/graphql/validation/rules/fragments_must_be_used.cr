# - For each fragment defined in the document.
# - fragment must be the target of at least one spread in the document
module Graphql
  module Validation
    class FragmentsMustBeUsed < Rule
      property fragments_defined : Set(String)
      property fragments_used : Set(String)

      def initialize(schema)
        super(schema)

        @fragments_defined = Set(String).new
        @fragments_used = Set(String).new
      end

      def enter(node : Graphql::Language::Nodes::FragmentDefinition)
        fragments_defined << node.name
      end

      def enter(node : Graphql::Language::Nodes::FragmentSpread)
        fragments_used << node.name
      end

      def exit(node : Graphql::Language::Nodes::Document)
        unused_fragments = fragments_defined - fragments_used
        unused_fragments.each do |fragment_name|
          errors << Error.new("fragment #{fragment_name} is defined but not used")
        end
      end
    end
  end
end