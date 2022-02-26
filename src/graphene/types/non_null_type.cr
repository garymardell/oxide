require "../type"

module Graphene
  module Types
    class NonNullType < Type
      getter of_type : Graphene::Type

      def initialize(@of_type)
      end

      def description
      end

      def kind
        "NON_NULL"
      end

      def coerce(value)
        value
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end