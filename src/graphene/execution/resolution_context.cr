module Graphene
  module Execution
    struct ResolutionContext
      getter schema : Graphene::Schema
      getter query : Graphene::Query
      getter field : Graphene::Schema::Field?
      getter context : Graphene::Context?

      def initialize(@schema, @query, @field = nil, @context = nil)
      end

      forward_missing_to @context
    end
  end
end