require "../type_resolver"
require "../type"

module Oxide
  module Types
    class UnionType < Type
      getter name : String
      getter description : String?
      getter type_resolver : TypeResolver
      getter possible_types : Array(Oxide::Type)
      getter applied_directives : Array(AppliedDirective)

      def initialize(@name, @type_resolver, @description = nil, @possible_types = [] of Oxide::Type, @applied_directives = [] of AppliedDirective)
      end

      def kind
        "UNION"
      end

      def coerce(schema, value) : JSON::Any::Type
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