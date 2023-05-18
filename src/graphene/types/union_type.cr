require "../type_resolver"
require "../type"

module Graphene
  module Types
    class UnionType < Type
      getter name : String
      getter description : String?
      getter type_resolver : TypeResolver
      getter possible_types : Array(Graphene::Type)

      def initialize(@name, @type_resolver, @description = nil, @possible_types = [] of Graphene::Type)
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

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
      end
    end
  end
end