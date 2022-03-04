module Graphene
  module Validation
    abstract class Rule
      def enter(node, context)
      end

      def leave(node, context)
      end
    end
  end
end