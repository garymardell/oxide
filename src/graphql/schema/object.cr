require "./member"

module Graphql
  class Schema
    class Object < Member
      getter typename : String

      def initialize(@typename : String, @resolver : Resolver, @fields = [] of Field)
      end

      def add_field(field : Field)
        @fields << field
      end

      def get_field(name)
        @fields.find(&.name.===(name))
      end
    end
  end
end
