module Graphql
  module DSL
    class Int
      def self.compile(context)
        Graphql::Type::Int.new
      end
    end
  end
end