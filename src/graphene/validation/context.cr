module Graphene
  module Validation
    class Context
      getter schema : Graphene::Schema
      getter query : Graphene::Query
      getter stack : Array(Graphene::Type)

      def initialize(@schema, @query)
        @stack = [] of Graphene::Type
      end
    end
  end
end