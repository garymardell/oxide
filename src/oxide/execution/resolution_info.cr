module Oxide
  module Execution
    struct ResolutionInfo
      getter schema : Oxide::Schema
      getter context : Execution::Context
      getter field : Oxide::BaseField?
      getter field_name : String

      delegate query, to: context

      def initialize(@schema, @context, @field, @field_name)
      end
    end
  end
end