module Graphql
  module DSL
    class Float
      def self.compile(context)
        Graphql::Type::Float.new
      end
    end
  end
end