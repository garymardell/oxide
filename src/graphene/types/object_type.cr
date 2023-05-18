require "../field"
require "../type"
require "./interface_type"

module Graphene
  module Types
    class ObjectType < Type
      getter fields : Hash(String, Field)
      getter name : String
      getter description : String?
      getter interfaces : Array(Graphene::Types::InterfaceType)
      getter resolver : Resolver?

      def initialize(
        @name,
        @resolver = nil,
        @description = nil,
        @fields = {} of String => Field,
        @interfaces = [] of Graphene::Types::InterfaceType
      )
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
          if false #argument_values["includeDeprecated"]?
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
        end
      end

      def kind
        "OBJECT"
      end

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
        coerce(value)
      end
    end
  end
end
