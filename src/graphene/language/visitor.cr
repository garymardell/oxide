module Graphene
  module Language
    abstract class Visitor
      def enter(node)
      end

      def exit(node)
      end
    end
  end
end