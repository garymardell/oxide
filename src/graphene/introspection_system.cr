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
  end
end