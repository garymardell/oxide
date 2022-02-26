require "../resolvable"
require "../field"
require "../type"
require "./interface_type"

module Graphene
  module Types
    class ObjectType < Type
      getter fields : Array(Field)
      getter name : String
      getter description : String?
      getter interfaces : Array(Graphene::Types::InterfaceType)
      getter resolver : Resolvable

      def initialize(
        @name,
        @resolver,
        @description = nil,
        @fields = [] of Field,
        @interfaces = [] of Graphene::Types::InterfaceType
      )
      end

      def add_field(field : Field)
        @fields << field
      end

      def get_field(name)
        all_fields.find(&.name.===(name))
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

      private def all_fields
        all_fields = [] of Field
        all_fields.concat fields

        interfaces.each do |interface|
          all_fields.concat interface.fields
        end

        all_fields
      end
    end
  end
end
