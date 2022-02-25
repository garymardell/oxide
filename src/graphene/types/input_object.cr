require "../type"

module Graphene
  module Types
    class InputObject < Type
      getter name : ::String
      getter description : ::String?
      getter input_fields : Array(Schema::InputValue)

      def initialize(@name, @description = nil, @input_fields = [] of Schema::InputValue)
      end

      def kind
        "INPUT_OBJECT"
      end

      def coerce(value)
        value
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end