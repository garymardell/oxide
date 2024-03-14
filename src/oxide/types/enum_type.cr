require "../type"

module Oxide
  module Types
    class EnumType < Type
      getter name : String
      getter description : String?
      getter values : Array(EnumValue)
      property directives : Array(Directive)

      def initialize(@name, @values, @description = nil, @directives = [] of Directive)
      end

      def coerce(value : String) : CoercedInput
        enum_value = values.find { |ev| ev.value == value }

        if enum_value
          enum_value.value
        else
          raise InputCoercionError.new("Value could be coerced into enum")
        end
      end

      def coerce(value) : CoercedInput
        raise InputCoercionError.new("Value could not be coerced")
      end

      def serialize(value) : SerializedOutput
        enum_value = values.find { |ev| ev.value == value.to_s }

        if enum_value
          enum_value.value
        else
          raise "Value could be coerced into enum"
        end
      end

      def kind
        "ENUM"
      end

      def input_type? : Bool
        true
      end

      def output_type? : Bool
        true
      end
    end

    class EnumValue
      getter name : String
      getter description : String?
      getter value : String
      getter deprecation_reason : String?
      property directives : Array(Directive)

      def initialize(@name, @description = nil, value = nil, @deprecation_reason = nil, @directives = [] of Directive)
        @value = value || @name
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
