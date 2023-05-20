require "../type"

module Graphene
  module Types
    class ListType < Type
      getter description : String?
      getter of_type : Graphene::Type

      def initialize(@of_type, @description = nil)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "kind"
          kind
        when "ofType"
          of_type
        end
      end

      def kind
        "LIST"
      end

      def coerce(value : Array) : Execution::Runtime::VariableType
        value.map do |item|
          of_type.coerce(item).as(Execution::Runtime::VariableType)
        end
      end

      def coerce(value) : Execution::Runtime::VariableType
        # value
        raise "Invalid"
      end

      def serialize(value)
        value
      end
    end
  end
end
