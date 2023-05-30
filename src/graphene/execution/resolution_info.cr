module Graphene
  module Execution
    struct ResolutionInfo
      getter schema : Graphene::Schema
      getter context : Execution::Context
      getter field : Graphene::Field?

      delegate query, to: context

      def initialize(@schema, @context, @field = nil)
      end
    end
  end
end