require "../type"

module Graphene
  module Types
    class NonNullType < Type
      getter of_type : Graphene::Type

      def initialize(@of_type)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "kind"
          kind
        when "ofType"
          of_type
        end
      end

      def description
      end

      def kind
        "NON_NULL"
      end

      def coerce(value) : CoercedInput
        if value.nil?
          raise InputCoercionError.new("NON_NULL received null value")
        else
          of_type.coerce(value)
        end
      end

      def serialize(value) : SerializedOutput
        coerce(value)
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