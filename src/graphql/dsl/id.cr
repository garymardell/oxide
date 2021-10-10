module Graphql
  module DSL
    class Id
      def self.compile(context)
        Graphql::Type::Id.new
      end
    end
  end
end