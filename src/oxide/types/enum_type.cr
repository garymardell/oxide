require "../type"

module Oxide
  module Types
    class EnumType < Type
      getter name : String
      getter description : String?
      getter values : Array(EnumValue)
      getter applied_directives : Array(AppliedDirective)

      def initialize(@name, @values, @description = nil, @applied_directives = [] of AppliedDirective)
      end

      def coerce(schema, value : String) : JSON::Any::Type
        enum_value = values.find { |ev| ev.value == value }

        if enum_value
          enum_value.value
        else
          raise InputCoercionError.new("Value could be coerced into enum")
        end
      end

      def coerce(schema, value) : JSON::Any::Type
        raise InputCoercionError.new("Value could not be coerced")
      end

      def serialize(value) : SerializedOutput
        enum_value = values.find { |ev| ev.value == value.to_s }

        if enum_value
          enum_value.value
        else
          raise SerializationError.new("Enum value could not be serialized")
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
      getter applied_directives : Array(AppliedDirective)

      def initialize(@name, @description = nil, value = nil, @deprecation_reason = nil, @applied_directives = [] of AppliedDirective)
        @value = value || @name
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
