require "../type_resolver"
require "../type"

module Graphene
  module Types
    class Interface < Type
      getter name : ::String
      getter description : ::String?
      getter type_resolver : TypeResolver
      getter interfaces : Array(Graphene::Types::Interface)
      getter fields : Array(Field)

      def initialize(@name, @type_resolver, @description = nil, @fields = [] of Field, @interfaces = [] of Graphene::Types::Interface)
      end

      def kind
        "INTERFACE"
      end

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
      end
    end
  end
end