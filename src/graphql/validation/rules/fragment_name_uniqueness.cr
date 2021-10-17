# - For each fragment definition fragment in the document
# - Let fragmentName be the name of fragment.
# - Let fragments be all fragment definitions in the document named fragmentName.
# - fragments must be a set of one.
module Graphql
  module Validation
    class FragmentNameUniqueness < Rule
      property fragment_names : Set(String)

      def initialize(schema)
        super(schema)

        @fragment_names = Set(String).new
      end

      def enter(node : Graphql::Language::Nodes::FragmentDefinition)
        fragment_name = node.name

        if fragment_names.includes?(fragment_name)
          errors << Error.new("multiple fragments defined with the name #{fragment_name}")
        else
          fragment_names << fragment_name
        end
      end
    end
  end
end