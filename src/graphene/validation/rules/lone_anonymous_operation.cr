# - Let operations be all operation definitions in the document.
# - Let anonymous be all anonymous operation definitions in the document.
# - If operations is a set of more than 1:
#   - anonymous must be empty.

module Graphene
  module Validation
    class LoneAnonymousOperation < Rule
      property operations : Array(Graphene::Language::Nodes::OperationDefinition)
      property anonymous : Array(Graphene::Language::Nodes::OperationDefinition)

      def initialize(schema)
        @operations = [] of Graphene::Language::Nodes::OperationDefinition
        @anonymous = [] of Graphene::Language::Nodes::OperationDefinition

        super(schema)
      end

      def enter(node : Graphene::Language::Nodes::OperationDefinition)
        operations << node

        unless node.name
          anonymous << node
        end

        if operations.size > 1 && anonymous.any?
          errors << Error.new("only one anonymous operation can be defined")
        end
      end
    end
  end
end