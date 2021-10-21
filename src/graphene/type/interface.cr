require "../schema/type_resolver"
require "../type"

module Graphene
  class Type
    class Interface < Type
      getter name : ::String
      getter type_resolver : Schema::TypeResolver
      getter fields : Array(Schema::Field)

      def initialize(@name : ::String, @type_resolver, @fields = [] of Schema::Field)
      end

      def kind
        "INTERFACE"
      end
    end
  end
end