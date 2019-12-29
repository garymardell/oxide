require "../type"

module Graphql
  class Type
    class Enum < Type
      getter values : Array(EnumValue)

      def initialize(@values : Array(EnumValue))
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
