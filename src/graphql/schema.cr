require "./schema/*"

module Graphql
  class Schema
    macro query(query)
      def self.query
        {{query}}
      end
    end

    macro mutation(mutation)
      def self.mutation
        {{mutation}}
      end
    end

    def self.query
      nil
    end

    def self.mutation
      nil
    end

    # property query : Graphql::Schema::Object | Nil
    # property mutation : Graphql::Schema::Object | Nil
    #
    # def initialize(@query, @mutation)
    # end
  end
end
