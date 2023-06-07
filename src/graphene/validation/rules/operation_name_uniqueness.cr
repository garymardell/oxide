module Graphene
  module Validation
    class OperationNameUniqueness < Rule
      def initialize
        @operation_names = [] of String
      end

      def enter(node : Graphene::Language::Nodes::OperationDefinition, context)
        if name = node.name
          if @operation_names.includes?(name)
            context.errors << Error.new("Operation name \"#{name}\" must be unique")
          else
            @operation_names << name
          end
        end
      end
    end
  end
end