require "../type"

module Graphene
  module Types
    class InputObject < Type
      getter name : ::String
      getter description : ::String?
      getter fields : Array(Schema::Field)

      def initialize(@name : ::String, @description : ::String? = nil, @fields = [] of Schema::Field)
      end

      def kind
        "INPUT_OBJECT"
      end

      def coerce(value)
        value
      end
    end
  end
end