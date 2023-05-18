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

      def coerce(value)
        value
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end