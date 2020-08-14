require "../schema/resolvable"
require "../schema/field"
require "../type"
require "./interface"

module Graphql
  class Type
    class Object < Type
      getter fields : Array(Schema::Field)
      getter typename : ::String
      getter implements : Array(Graphql::Type::Interface)

      def initialize(@typename : ::String, @resolver : Schema::Resolvable, @fields = [] of Schema::Field, @implements = [] of Graphql::Type::Interface)
      end

      def add_field(field : Schema::Field)
        @fields << field
      end

      def get_field(name)
        all_fields.find(&.name.===(name))
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
