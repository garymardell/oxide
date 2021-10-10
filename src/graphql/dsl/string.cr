module Graphql
  module DSL
    class String
      def self.compile(context)
        Graphql::Type::String.new
      end
    end
  end
end