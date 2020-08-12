module Graphql
  class Schema
    abstract class Visitor
      def visit(type)
      end
    end
  end
end
