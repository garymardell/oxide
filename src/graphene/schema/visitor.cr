module Graphene
  class Schema
    abstract class Visitor
      def visit(type)
      end
    end
  end
end
