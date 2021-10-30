require "../schema/resolvable"
require "../schema/field"
require "../type"
require "./interface"

module Graphene
  module Types
    class Object < Type
      getter fields : Array(Schema::Field)
      getter name : ::String
      getter implements : Array(Graphene::Types::Interface)

      def initialize(@name : ::String, @fields = [] of Schema::Field, @implements = [] of Graphene::Types::Interface)
      end

      def add_field(field : Schema::Field)
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

      private def all_fields
        all_fields = [] of Schema::Field
        all_fields.concat fields

        implements.each do |interface|
          all_fields.concat interface.fields
        end

        all_fields
      end
    end
  end
end
