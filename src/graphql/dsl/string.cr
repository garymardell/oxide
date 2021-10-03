module Graphql
  module DSL
    class String
      def self.compile
        Graphql::Type::String.new
      end
    end
  end
end