require "../type"

module Oxide
  module Types
    class ListType < Type
      getter description : String?
      getter of_type : Oxide::Type

      def initialize(@of_type, @description = nil)
      end

      def name
        "[#{of_type.name}]"
      end

      def kind
        "LIST"
      end

      def coerce(schema, value : JSON::Any) : JSON::Any::Type
        coerce(schema, value.as_a)
      end

      def coerce(schema, value : Array) : JSON::Any::Type
        value.map do |item|
          case of_type
          when ListType
            unless item.is_a?(Array)
              raise InputCoercionError.new("Incorrect item value")
            end

            JSON::Any.new(schema.resolve_type(of_type).coerce(schema, item))
          else
            JSON::Any.new(schema.resolve_type(of_type).coerce(schema, item))
          end
        end.as(JSON::Any::Type)
      end

      def coerce(schema, value : Nil) : JSON::Any::Type
        value
      end

      def coerce(schema, value : Oxide::Language::Nodes::ListValue) : JSON::Any::Type
        value.values.map do |item|
          JSON::Any.new(schema.resolve_type(of_type).coerce(schema, item))
        end
      end

      def coerce(schema, value) : JSON::Any::Type
        Array(JSON::Any).new(1, JSON::Any.new(schema.resolve_type(of_type).coerce(schema, value))).as(JSON::Any::Type)
      end

      def serialize(value) : SerializedOutput
        value
      end

      def input_type? : Bool
        of_type.input_type?
      end

      def output_type? : Bool
        of_type.output_type?
      end
    end
  end
end
