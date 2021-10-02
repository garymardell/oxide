module Graphql
  module DSL
    class Boolean
      def self.compile
        Graphql::Type::Boolean.new
      end
    end

  end
end