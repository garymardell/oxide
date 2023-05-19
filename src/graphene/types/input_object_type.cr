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

      def coerce(value : JSON::Any)
        coerce(value.as_h)
      end

      def coerce(value : Hash)
        cooerced_values = Hash(String, Execution::Runtime::VariableType).new

        input_fields.each do |name, argument|
          has_value = value.has_key?(name)

          if has_value
            cooerced_values[name] = argument.type.coerce(value[name]).as(Execution::Runtime::VariableType)
          else
            if argument.has_default_value?
              cooerced_values[name] = argument.type.coerce(argument.default_value).as(Execution::Runtime::VariableType)
            end
          end
        end

        cooerced_values
      end

      def coerce(value)
        raise Execution::Runtime::InputCoercionError.new("INPUT_OBJECT did not receive a hash")
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end