require "../type"
require "../input_value"

module Graphene
  module Types
    class InputObjectType < Type
      getter name : String
      getter description : String?
      getter input_fields : Array(InputValue)

      def initialize(@name, @description = nil, @input_fields = [] of InputValue)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
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