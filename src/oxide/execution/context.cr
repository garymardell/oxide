module Oxide
  module Execution
    class Context
      delegate document, to: query

      getter schema : Oxide::Schema
      getter query : Oxide::Query
      getter! context : Oxide::Context

      property current_path : Array(String | Int32)
      property current_object : Oxide::Types::ObjectType?
      property current_field : Oxide::Language::Nodes::Field?

      getter errors : Set(RuntimeError)

      def initialize(@schema : Oxide::Schema, @query : Oxide::Query, @context : Oxide::Context? = nil)
        @current_path = [] of (String | Int32)
        @errors = Set(RuntimeError).new
      end
    end
  end
end