module Graphql
  module DSL
    class Float
      def self.compile
        Graphql::Type::Float.new
      end
    end

  end
end