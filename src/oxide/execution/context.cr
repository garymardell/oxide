module Oxide
  module Execution
    class Context
      delegate document, to: query

      property query : Oxide::Query

      property current_path : Array(String)
      property current_object : Oxide::Types::ObjectType?
      property current_field : Oxide::Language::Nodes::Field?

      property errors : Set(Error)

      def initialize(@query : Oxide::Query)
        @current_path = [] of String
        @errors = Set(Error).new
      end
    end
  end
end