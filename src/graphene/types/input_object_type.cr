require "../type"

module Graphene
  module Types
    class InputObjectType < Type
      getter name : String
      getter description : String?
      getter input_fields : Hash(String, Argument)

      def initialize(@name, @description = nil, @input_fields = {} of String => Argument)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "kind"
          kind
        when "description"
          description
        when "inputFields"
          input_fields.map { |name, argument| Introspection::ArgumentInfo.new(name, argument).as(Resolvable) }
        end
      end

      def kind
        "INPUT_OBJECT"
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