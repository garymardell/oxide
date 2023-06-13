module Oxide
  class IntrospectionSystem
    def self.types
      {
        "__Type" => Oxide::Introspection::TypeType,
        "__Schema" => Oxide::Introspection::SchemaType,
        "__InputValue" => Oxide::Introspection::InputValueType,
        "__Directive" => Oxide::Introspection::DirectiveType,
        "__EnumValue" => Oxide::Introspection::EnumValueType,
        "__Field" => Oxide::Introspection::FieldType
      }
    end

    def self.resolvers
      {
        "__Type" => Oxide::DefaultResolver.new,
        "__Schema" => Oxide::DefaultResolver.new,
        "__InputValue" => Oxide::DefaultResolver.new,
        "__Directive" => Oxide::DefaultResolver.new,
        "__EnumValue" => Oxide::DefaultResolver.new,
        "__Field" => Oxide::DefaultResolver.new,
      }
    end
  end
end