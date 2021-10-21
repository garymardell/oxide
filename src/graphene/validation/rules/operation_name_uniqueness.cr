# - For each operation definition operation in the document.
# - Let operationName be the name of operation.
# - If operationName exists
#   - Let operations be all operation definitions in the document named operationName.
#   - operations must be a set of one.

module Graphene
  module Validation
    class OperationNameUniqueness < Rule
      private property operation_names : Set(String)

      def initialize(schema)
        @operation_names = Set(String).new

        super(schema)
      end

      def enter(node : Graphene::Language::Nodes::OperationDefinition)
        return if node.name.nil?

        operation_name = node.name.not_nil!

        if operation_names.includes?(operation_name)
          errors << Error.new("multiple operations found with the name #{node.name}")
        end

        operation_names << operation_name
      end
    end
  end
end