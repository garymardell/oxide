require "../schema/type_resolver"
require "../type"

module Graphene
  module Types
    class Union < Type
      getter name : ::String
      getter description : ::String?
      getter type_resolver : Schema::TypeResolver
      getter possible_types : Array(Graphene::Type)

      def initialize(@name, @type_resolver, @description = nil, @possible_types = [] of Graphene::Type)
      end

      def kind
        "UNION"
      end

      def coerce(value)
        raise "Invalid input type"
      end
    end
  end
end