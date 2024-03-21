module Oxide
  module Execution
    class Context
      delegate document, to: query

      getter query : Oxide::Query
      getter context : Oxide::Context?

      property current_path : Array(String)
      property current_object : Oxide::Types::ObjectType?
      property current_field : Oxide::Language::Nodes::Field?

      getter errors : Set(Error)

      def initialize(@query : Oxide::Query, @context : Oxide::Context? = nil)
        @current_path = [] of String
        @errors = Set(Error).new
      end
    end
  end
end