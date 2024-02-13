require "../type"

module Oxide
  module Types
    class LateBoundType < Type
      getter typename : String

      def initialize(@typename)
      end

      def name
        "LateBound"
      end

      def kind
      end

      def description
      end

      def coerce(value) : CoercedInput
        raise InputCoercionError.new("Invalid input type")
      end

      def serialize(value) : SerializedOutput
      end

      def input_type? : Bool
        false
      end

      def output_type? : Bool
        false
      end

      private def get_type(schema, typename)
        case typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
          IntrospectionSystem.types[typename]
        else
          schema.get_type!(typename)
        end
      end
    end
  end
end
