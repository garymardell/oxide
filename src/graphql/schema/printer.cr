require "./visitor"

module Graphql
  class Schema
    class Printer < Visitor
      private property schema : Graphql::Schema

      def initialize(@schema)
      end

      def print
        roots = [schema.query].flatten
        roots.each do |type|
          # type.accept(self)
        end
      end
    end
  end
end