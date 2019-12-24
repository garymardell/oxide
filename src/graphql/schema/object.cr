require "./member"

module Graphql
  class Schema
    class Object < Member
      getter name : String

      def initialize(@name : String, @resolver : Resolver, @fields = [] of Field)
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
