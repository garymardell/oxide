module Graphql
  class Schema
    class Object < Member
      property fields : Array(Graphql::Schema::Field)

      def initialize(@fields = [] of Graphql::Schema::Field)
      end

      def add_field(field)
        @fields << field
      end
    end
  end
end
