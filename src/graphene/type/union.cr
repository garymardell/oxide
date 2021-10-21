require "../schema/type_resolver"
require "../type"

module Graphene
  class Type
    class Union < Type
      getter typename : ::String
      getter possible_types : Array(Graphene::Type)
      getter type_resolver : Schema::TypeResolver

      def initialize(@typename : ::String, @type_resolver : Schema::TypeResolver, @possible_types = [] of Graphene::Type)
      end

      def kind
        "UNION"
      end
    end
  end
end