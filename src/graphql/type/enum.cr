require "../type"

module Graphql
  class Type
    class Enum < Type
      getter typename : ::String
      getter values : Array(EnumValue)

      def initialize(@typename : ::String, @values : Array(EnumValue))
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
    end
  end
end
