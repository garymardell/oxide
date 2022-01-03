require "../type"

module Graphene
  module Types
    class Enum < Type
      getter name : ::String
      getter description : ::String?
      getter values : Array(EnumValue)

      def initialize(@name : ::String, @values : Array(EnumValue), @description : ::String? = nil)
      end

      def coerce(value)
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
      getter name : ::String
      getter description : ::String?
      getter value : ::String
      getter deprecation_reason : ::String?

      def initialize(@name : ::String, @description : ::String? = nil, value : ::String? = nil, @deprecation_reason : ::String? = nil)
        @value = value || @name
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
