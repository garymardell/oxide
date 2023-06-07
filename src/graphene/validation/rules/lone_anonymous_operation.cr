module Graphene
  module Validation
    class LoneAnonymousOperation < Rule
      def initialize
        @operations = [] of Graphene::Language::Nodes::OperationDefinition
        @anonymous_operations = [] of Graphene::Language::Nodes::OperationDefinition
      end

      def enter(node : Graphene::Language::Nodes::OperationDefinition, context)
        if node.name
          @operations << node
        else
          @anonymous_operations << node
        end
      end

      def leave(node : Graphene::Language::Nodes::Document, context)
        if @operations.size > 0 && @anonymous_operations.size > 0
          context.errors << Error.new("Operation name is required when multiple operations are present")
        end
      end
    end
  end
end