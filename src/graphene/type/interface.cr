require "../schema/type_resolver"
require "../type"

module Graphene
  class Type
    class Interface < Type
      getter name : ::String
      getter fields : Array(Schema::Field)

      def initialize(@name : ::String, @fields = [] of Schema::Field)
      end

      def kind
        "INTERFACE"
      end
    end
  end
end