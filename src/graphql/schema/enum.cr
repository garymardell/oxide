require "./member"

module Graphql
  class Schema
    class Enum < Member
      property values : Array(EnumValue)

      def initialize(@values)
      end
    end

    class EnumValue
      property name : String
      property description : String | Nil
      property value : String
      property deprecation_reason : String | Nil

      def initialize(@name, @description = nil, value = nil, @deprecation_reason = nil)
        @value = value || @name
      end
    end
  end
end
