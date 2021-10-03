module Graphql
  module DSL
    class Id
      def self.compile
        Graphql::Type::Id.new
      end
    end
  end
end