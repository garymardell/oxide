module Graphql
  class Schema
    class Object < Member
      def initialize(@resolver, @fields = [] of Field)
      end

      def add_field(field)
        @fields << field
      end

      def get_field(name)
        @fields.find(&.name.===(name))
      end
    end
  end
end
