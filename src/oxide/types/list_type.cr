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

      def coerce(value : Array) : JSON::Any::Type
        value.map do |item|
          case of_type
          when ListType
            unless item.is_a?(Array)
              raise InputCoercionError.new("Incorrect item value")
            end

            JSON::Any.new(of_type.coerce(item))
          else
            JSON::Any.new(of_type.coerce(item))
          end
        end.as(JSON::Any::Type)
      end

      def coerce(value : Nil) : JSON::Any::Type
        value
      end

      def coerce(value : Oxide::Language::Nodes::ListValue) : JSON::Any::Type
        value.values.map do |item|
          JSON::Any.new(of_type.coerce(item))
        end
      end

      def coerce(value) : JSON::Any::Type
        Array(JSON::Any).new(1, JSON::Any.new(of_type.coerce(value))).as(JSON::Any::Type)
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
