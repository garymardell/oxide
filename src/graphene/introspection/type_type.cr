require "./field_type"
require "./enum_value_type"
require "./input_value_type"

module Graphene
  module Introspection
    TypeKindType = Graphene::Types::EnumType.new(
      name: "__TypeKind",
      values: [
        Graphene::Types::EnumValue.new(name: "SCALAR"),
        Graphene::Types::EnumValue.new(name: "OBJECT"),
        Graphene::Types::EnumValue.new(name: "INTERFACE"),
        Graphene::Types::EnumValue.new(name: "UNION"),
        Graphene::Types::EnumValue.new(name: "ENUM"),
        Graphene::Types::EnumValue.new(name: "INPUT_OBJECT"),
        Graphene::Types::EnumValue.new(name: "LIST"),
        Graphene::Types::EnumValue.new(name: "NON_NULL")
      ]
    )

    TypeType = Graphene::Types::ObjectType.new(
      name: "__Type",
      resolver: TypeResolver.new,
      fields: {
        "kind" => Graphene::Field.new(
          name: "kind",
          type: Graphene::Types::NonNullType.new(of_type: TypeKindType)
        ),
        "name" => Graphene::Field.new(
          name: "name",
          type: Graphene::Types::StringType.new
        ),
        "description" => Graphene::Field.new(
          name: "description",
          type: Graphene::Types::StringType.new
        ),
        "fields" => Graphene::Field.new(
          name: "fields",
          arguments: {
            "includeDeprecated" => Graphene::Argument.new(
              name: "includeDeprecated",
              type: Graphene::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Graphene::Types::ListType.new(
            of_type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::LateBoundType.new("__Field") # Introspection::Field
            )
          )
        ),
        "interfaces" => Graphene::Field.new(
          name: "interfaces",
          type: Graphene::Types::ListType.new(
            of_type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::LateBoundType.new("__Type")  # Introspection::Type
            )
          )
        ),
        "possibleTypes" => Graphene::Field.new(
          name: "possibleTypes",
          type: Graphene::Types::ListType.new(
            of_type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::LateBoundType.new("__Type")
            )
          )
        ),
        "enumValues" => Graphene::Field.new(
          name: "enumValues",
          arguments: {
            "includeDeprecated" => Graphene::Argument.new(
              name: "includeDeprecated",
              type: Graphene::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Graphene::Types::ListType.new(
            of_type: Graphene::Types::NonNullType.new(
              of_type: Introspection::EnumValueType
            )
          )
        ),
        "inputFields" => Graphene::Field.new(
          name: "inputFields",
          type: Graphene::Types::ListType.new(
            of_type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::LateBoundType.new("__InputValue") # Introspection::InputValue
            )
          )
        ),
        "ofType" => Graphene::Field.new(
          name: "ofType",
          type: Graphene::Types::LateBoundType.new("__Type")
        )
      }
    )
  end
end