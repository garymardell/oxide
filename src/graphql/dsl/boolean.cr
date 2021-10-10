module Graphql
  module DSL
    class Boolean
      def self.compile(context)
        Graphql::Type::Boolean.new
      end
    end
  end
end