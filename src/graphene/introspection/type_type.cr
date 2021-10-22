require "./field_type"
require "./enum_value_type"
require "./input_value_type"

module Graphene
  module Introspection
    TypeKindType = Graphene::Type::Enum.new(
      name: "__TypeKind",
      values: [
        Graphene::Type::EnumValue.new(name: "SCALAR"),
        Graphene::Type::EnumValue.new(name: "OBJECT"),
        Graphene::Type::EnumValue.new(name: "INTERFACE"),
        Graphene::Type::EnumValue.new(name: "UNION"),
        Graphene::Type::EnumValue.new(name: "ENUM"),
        Graphene::Type::EnumValue.new(name: "INPUT_OBJECT"),
        Graphene::Type::EnumValue.new(name: "LIST"),
        Graphene::Type::EnumValue.new(name: "NON_NULL")
      ]
    )

    TypeType = Graphene::Type::Object.new(
      name: "__Type",
      fields: [
        Graphene::Schema::Field.new(
          name: "kind",
          type: Graphene::Type::NonNull.new(of_type: TypeKindType)
        ),
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Type::String.new
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Type::String.new
        ),
        Graphene::Schema::Field.new(
          name: "fields",
          arguments: [
            Graphene::Schema::Argument.new(
              name: "includeDeprecated",
              type: Graphene::Type::Boolean.new,
              default_value: false
            )
          ],
          type: Graphene::Type::List.new(
            of_type: Graphene::Type::NonNull.new(
              of_type: Graphene::Type::LateBound.new("__Field") # Introspection::Field
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "interfaces",
          type: Graphene::Type::List.new(
            of_type: Graphene::Type::NonNull.new(
              of_type: Graphene::Type::LateBound.new("__Type")  # Introspection::Type
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "possibleTypes",
          type: Graphene::Type::List.new(
            of_type: Graphene::Type::NonNull.new(
              of_type: Graphene::Type::LateBound.new("__Type")
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "enumValues",
          type: Graphene::Type::List.new(
            of_type: Graphene::Type::NonNull.new(
              of_type: Introspection::EnumValueType
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "inputFields",
          type: Graphene::Type::List.new(
            of_type: Graphene::Type::NonNull.new(
              of_type: Graphene::Type::LateBound.new("__InputValue") # Introspection::InputValue
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "ofType",
          type: Graphene::Type::LateBound.new("__Type")
        )
      ]
    )
  end
end