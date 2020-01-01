require "../schema/resolver"
require "../schema/field"
require "../type"

module Graphql
  class Type
    class Object < Type
      getter fields : Array(Schema::Field)
      getter typename : ::String

      def initialize(@typename : ::String, @resolver : Schema::Resolver, @fields = [] of Schema::Field)
      end

      def add_field(field : Schema::Field)
        @fields << field
      end

      def get_field(name)
        @fields.find(&.name.===(name))
      end
    end
  end
end
