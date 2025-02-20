require "../type"

module Oxide
  module Types
    class InputObjectType < Type
      getter name : String
      getter description : String?
      getter input_fields : Hash(String, Argument)
      getter applied_directives : Array(AppliedDirective)

      def initialize(@name, @description = nil, @input_fields = {} of String => Argument, @applied_directives = [] of AppliedDirective)
      end

      def kind
        "INPUT_OBJECT"
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        coerce(value.as_h)
      end

      def coerce(value : Oxide::Language::Nodes::ObjectValue) : JSON::Any::Type
        cooerced_values = Hash(String, JSON::Any).new
        object_value = value.value

        input_fields.each do |name, argument|
          has_value = object_value.has_key?(name)

          if has_value
            cooerced_values[name] = if object_value[name].nil?
              nil
            else
              JSON::Any.new(argument.type.coerce(object_value[name]))
            end
          else
            if argument.has_default_value?
              cooerced_values[name] = JSON::Any.new(argument.type.coerce(argument.default_value))
            end
          end
        end

        cooerced_values
      end

      def coerce(value : Hash) : JSON::Any::Type
        cooerced_values = Hash(String, JSON::Any).new

        input_fields.each do |name, argument|
          has_value = value.has_key?(name)

          if has_value
            cooerced_values[name] = JSON::Any.new(argument.type.coerce(value[name]))
          else
            if argument.has_default_value?
              cooerced_values[name] = JSON::Any.new(argument.type.coerce(argument.default_value))
            end
          end
        end

        cooerced_values.as(JSON::Any::Type)
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("INPUT_OBJECT did not receive a hash")
      end

      def serialize(value) : SerializedOutput
        coerce(value)
      end

      def input_type? : Bool
        true
      end

      def output_type? : Bool
        false
      end
    end
  end
end