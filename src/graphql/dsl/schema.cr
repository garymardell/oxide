require "./object"

module Graphql
  module DSL
    class Schema
      def self.query(object : Graphql::DSL::Object.class)
        @@query = object
      end

      def self.query
        @@query
      end

      def self.to_definition : Graphql::Schema
        Graphql::Schema.new(
          query: @@query.try &.to_definition
        )
      end
    end
  end
end