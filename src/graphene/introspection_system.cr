module Graphene
  class IntrospectionSystem
    def self.types
      {
        "__Type" => Graphene::Introspection::TypeType,
        "__Schema" => Graphene::Introspection::SchemaType,
        "__InputValue" => Graphene::Introspection::InputValueType,
        "__Directive" => Graphene::Introspection::DirectiveType,
        "__EnumValue" => Graphene::Introspection::EnumValueType,
        "__Field" => Graphene::Introspection::FieldType
      }
    end

    def self.resolvers
      {
        "__Type" => Graphene::Introspection::TypeResolver.new,
        "__Schema" => Graphene::Introspection::SchemaResolver.new,
        "__InputValue" => Graphene::Introspection::InputValueResolver.new,
        "__Directive" => Graphene::Introspection::DirectiveResolver.new,
        "__EnumValue" => Graphene::Introspection::EnumValueResolver.new,
        "__Field" => Graphene::Introspection::FieldResolver.new
      }
    end
  end
end