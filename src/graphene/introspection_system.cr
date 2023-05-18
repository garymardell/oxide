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
        "__Type" => Graphene::DefaultResolver.new,
        "__Schema" => Graphene::DefaultResolver.new,
        "__InputValue" => Graphene::DefaultResolver.new,
        "__Directive" => Graphene::DefaultResolver.new,
        "__EnumValue" => Graphene::DefaultResolver.new,
        "__Field" => Graphene::DefaultResolver.new,
      }
    end
  end
end