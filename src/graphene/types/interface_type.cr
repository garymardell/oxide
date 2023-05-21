require "../type_resolver"
require "../type"

module Graphene
  module Types
    class InterfaceType < Type
      getter name : String
      getter description : String?
      getter type_resolver : TypeResolver
      getter interfaces : Array(Graphene::Types::InterfaceType)
      getter fields : Hash(String, Field)

      def initialize(@name, @type_resolver, @description = nil, @fields = {} of String => Field, @interfaces = [] of Graphene::Types::InterfaceType)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          description
        when "kind"
          kind
        when "fields"
          if argument_values["includeDeprecated"]?
            fields.map do |name, field|
              Introspection::FieldInfo.new(name, field).as(Resolvable)
            end
          else
            fields.reject { |_, field| field.deprecated? }.map do |name, field|
              Introspection::FieldInfo.new(name, field).as(Resolvable)
            end
          end
        when "interfaces"
          interfaces.map { |interface| interface.as(Resolvable) }
        when "possibleTypes"
          resolution_info.schema.not_nil!.type_map.each_with_object([] of Graphene::Resolvable) do |(_, type), memo|
            if type.responds_to?(:interfaces) && type.interfaces.includes?(self)
              memo << type
            end
          end
        end
      end

      def kind
        "INTERFACE"
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Invalid input type")
      end

      def serialize(value)
      end
    end
  end
end