require "../schema/type_resolver"
require "../type"

module Graphql
  class Type
    class Union < Type
      getter typename : ::String
      getter possible_types : Array(Graphql::Type)
      getter type_resolver : Schema::TypeResolver

      def initialize(@typename : ::String, @type_resolver : Schema::TypeResolver, @possible_types = [] of Graphql::Type)
      end

      def kind
        "UNION"
      end
    end
  end
end