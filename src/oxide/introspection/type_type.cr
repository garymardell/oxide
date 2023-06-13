require "./field_type"
require "./enum_value_type"
require "./input_value_type"

module Oxide
  module Introspection
    TypeKindType = Oxide::Types::EnumType.new(
      name: "__TypeKind",
      values: [
        Oxide::Types::EnumValue.new(name: "SCALAR"),
        Oxide::Types::EnumValue.new(name: "OBJECT"),
        Oxide::Types::EnumValue.new(name: "INTERFACE"),
        Oxide::Types::EnumValue.new(name: "UNION"),
        Oxide::Types::EnumValue.new(name: "ENUM"),
        Oxide::Types::EnumValue.new(name: "INPUT_OBJECT"),
        Oxide::Types::EnumValue.new(name: "LIST"),
        Oxide::Types::EnumValue.new(name: "NON_NULL")
      ]
    )

    TypeType = Oxide::Types::ObjectType.new(
      name: "__Type",
      resolver: DefaultResolver.new,
      fields: {
        "kind" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(of_type: TypeKindType)
        ),
        "name" => Oxide::Field.new(
          type: Oxide::Types::StringType.new
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new
        ),
        "fields" => Oxide::Field.new(
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Field") # Introspection::Field
            )
          )
        ),
        "interfaces" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Type")  # Introspection::Type
            )
          )
        ),
        "possibleTypes" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Type")
            )
          )
        ),
        "enumValues" => Oxide::Field.new(
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Introspection::EnumValueType
            )
          )
        ),
        "inputFields" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__InputValue") # Introspection::InputValue
            )
          )
        ),
        "ofType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type")
        )
      }
    )
  end
end