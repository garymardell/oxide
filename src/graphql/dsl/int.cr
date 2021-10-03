module Graphql
  module DSL
    class Int
      def self.compile
        Graphql::Type::Int.new
      end
    end
  end
end