module Graphql
  class Schema
    class Object
      def initialize(@fields : Array(Field))
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
