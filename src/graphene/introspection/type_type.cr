require "./field_type"
require "./enum_value_type"
require "./input_value_type"

module Graphene
  module Introspection
    TypeKindType = Graphene::Types::Enum.new(
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

    TypeType = Graphene::Types::Object.new(
      name: "__Type",
      resolver: TypeResolver.new,
      fields: [
        Graphene::Schema::Field.new(
          name: "kind",
          type: Graphene::Types::NonNull.new(of_type: TypeKindType)
        ),
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Types::String.new
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Types::String.new
        ),
        Graphene::Schema::Field.new(
          name: "fields",
          arguments: [
            Graphene::Schema::Argument.new(
              name: "includeDeprecated",
              type: Graphene::Types::Boolean.new,
              default_value: false
            )
          ],
          type: Graphene::Types::List.new(
            of_type: Graphene::Types::NonNull.new(
              of_type: Graphene::Types::LateBound.new("__Field") # Introspection::Field
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "interfaces",
          type: Graphene::Types::List.new(
            of_type: Graphene::Types::NonNull.new(
              of_type: Graphene::Types::LateBound.new("__Type")  # Introspection::Type
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "possibleTypes",
          type: Graphene::Types::List.new(
            of_type: Graphene::Types::NonNull.new(
              of_type: Graphene::Types::LateBound.new("__Type")
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "enumValues",
          type: Graphene::Types::List.new(
            of_type: Graphene::Types::NonNull.new(
              of_type: Introspection::EnumValueType
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "inputFields",
          type: Graphene::Types::List.new(
            of_type: Graphene::Types::NonNull.new(
              of_type: Graphene::Types::LateBound.new("__InputValue") # Introspection::InputValue
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "ofType",
          type: Graphene::Types::LateBound.new("__Type")
        )
      ]
    )
  end
end