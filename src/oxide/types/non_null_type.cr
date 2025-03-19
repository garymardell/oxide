require "../type"

module Oxide
  module Types
    class NonNullType < Type
      getter of_type : Oxide::Type

      def initialize(@of_type)
      end

      def name
        nil
      end

      def description
      end

      def kind
        "NON_NULL"
      end

      def coerce(schema, value) : JSON::Any::Type
        if value.nil?
          raise InputCoercionError.new("NON_NULL received null value")
        else
          schema.resolve_type(of_type).coerce(schema, value)
        end
      end

      def serialize(value) : SerializedOutput
        value
      end

      def input_type? : Bool
        of_type.input_type?
      end

      def output_type? : Bool
        of_type.output_type?
      end
    end
  end
end