require "../type"

module Graphene
  module Types
    class EnumType < Type
      getter name : String
      getter description : String?
      getter values : Array(EnumValue)

      def initialize(@name, @values, @description = nil)
      end

      def coerce(value : String)
        enum_value = values.find { |ev| ev.value == value }

        if enum_value
          enum_value.value
        else
          raise "Value could be coerced into enum"
        end
      end

      def coerce(value)
        raise "Value could not be coerced"
      end

      def serialize(value)
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
    end

    class EnumValue
      getter name : String
      getter description : String?
      getter value : String
      getter deprecation_reason : String?

      def initialize(@name, @description = nil, value = nil, @deprecation_reason = nil)
        @value = value || @name
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
