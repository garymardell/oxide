module Graphene
  module Execution
    class Context
      delegate document, to: query

      property query : Graphene::Query

      property current_path : Array(String)
      property current_object : Graphene::Types::ObjectType?
      property current_field : Graphene::Language::Nodes::Field?

      property errors : Set(Error)

      def initialize(@query : Graphene::Query)
        @current_path = [] of String
        @errors = Set(Error).new
      end
    end
  end
end