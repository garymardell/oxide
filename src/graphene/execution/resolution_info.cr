module Graphene
  module Execution
    struct ResolutionInfo
      getter schema : Graphene::Schema
      getter query : Graphene::Query
      getter field : Graphene::Field?

      def initialize(@schema, @query, @field = nil)
      end
    end
  end
end