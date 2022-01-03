require "../schema/type_resolver"
require "../type"

module Graphene
  module Types
    class Interface < Type
      getter name : ::String
      getter description : ::String?
      getter type_resolver : Schema::TypeResolver
      getter fields : Array(Schema::Field)

      def initialize(@name, @type_resolver, @description : ::String? = nil, @fields = [] of Schema::Field)
      end

      def kind
        "INTERFACE"
      end

      def coerce(value)
        raise "Invalid input type"
      end
    end
  end
end