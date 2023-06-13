require "../type_resolver"
require "../type"

module Oxide
  module Types
    class UnionType < Type
      getter name : String
      getter description : String?
      getter type_resolver : TypeResolver
      getter possible_types : Array(Oxide::Type)

      def initialize(@name, @type_resolver, @description = nil, @possible_types = [] of Oxide::Type)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          description
        when "kind"
          kind
        when "possibleTypes"
          possible_types.map { |type| type.as(Resolvable) }
        end
      end

      def kind
        "UNION"
      end

      def coerce(value) : CoercedInput
        raise InputCoercionError.new("Invalid input type")
      end

      def serialize(value) : SerializedOutput
      end

      def input_type? : Bool
        false
      end

      def output_type? : Bool
        true
      end
    end
  end
end