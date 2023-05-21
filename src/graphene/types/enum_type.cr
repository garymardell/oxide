require "../type"

module Graphene
  module Types
    class EnumType < Type
      getter name : String
      getter description : String?
      getter values : Array(EnumValue)

      def initialize(@name, @values, @description = nil)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          description
        when "kind"
          kind
        when "enumValues"
          if argument_values["includeDeprecated"]?
            values.map { |value| value.as(Resolvable) }
          else
            values.reject(&.deprecated?).map { |value| value.as(Resolvable) }
          end
        end
      end

      def coerce(value : String) : Execution::Runtime::VariableType
        enum_value = values.find { |ev| ev.value == value }

        if enum_value
          enum_value.value
        else
          raise Execution::Runtime::InputCoercionError.new("Value could be coerced into enum")
        end
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Value could not be coerced")
      end

      def serialize(value)
        enum_value = values.find { |ev| ev.value == value.to_s }

        if enum_value
          enum_value.value
        else
          raise "Value could be coerced into enum"
        end
      end

      def kind
        "ENUM"
      end
    end

    class EnumValue
      include Resolvable

      getter name : String
      getter description : String?
      getter value : String
      getter deprecation_reason : String?

      def initialize(@name, @description = nil, value = nil, @deprecation_reason = nil)
        @value = value || @name
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          description
        when "isDeprecated"
          deprecated?
        when "deprecationReason"
          deprecation_reason
        end
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
