require "../type"

module Graphene
  module Types
    class LateBoundType < Type
      getter typename : String

      def initialize(@typename)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        unwrapped_type = get_type(resolution_info.schema, typename)
        unwrapped_type.resolve(field_name, argument_values, context, resolution_info)
      end

      def description
      end

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
      end

      private def get_type(schema, typename)
        case typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
          IntrospectionSystem.types[typename]
        else
          schema.get_type(typename)
        end
      end
    end
  end
end
