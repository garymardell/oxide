require "../type_resolver"
require "../type"

module Graphene
  module Types
    class InterfaceType < Type
      getter name : String
      getter description : String?
      getter type_resolver : TypeResolver
      getter interfaces : Array(Graphene::Types::InterfaceType)
      getter fields : Hash(String, Field)

      def initialize(@name, @type_resolver, @description = nil, @fields = {} of String => Field, @interfaces = [] of Graphene::Types::InterfaceType)
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