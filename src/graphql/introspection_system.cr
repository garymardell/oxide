module Graphql
  class IntrospectionSystem
    def self.types
      {
        "__Type" => Graphql::Introspection::TypeType,
        "__Schema" => Graphql::Introspection::SchemaType,
        "__InputValue" => Graphql::Introspection::InputValueType,
        "__Directive" => Graphql::Introspection::DirectiveType,
        "__EnumValue" => Graphql::Introspection::EnumValueType,
        "__Field" => Graphql::Introspection::FieldType
      }
    end
  end
end