require "../resolvable"
require "../field"
require "../type"
require "./interface_type"

module Graphene
  module Types
    class ObjectType < Type
      getter fields : Hash(String, Field)
      getter name : String
      getter description : String?
      getter interfaces : Array(Graphene::Types::InterfaceType)
      getter resolver : Resolvable

      def initialize(
        @name,
        @resolver,
        @description = nil,
        @fields = {} of String => Field,
        @interfaces = [] of Graphene::Types::InterfaceType
      )
      end

      def kind
        "OBJECT"
      end

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end
