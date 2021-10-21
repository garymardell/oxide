require "./input_value_type"

module Graphene
  module Introspection
    DirectiveLocationType = Graphene::Type::Enum.new(
      typename: "__DirectiveLocation",
      values: [
        Graphene::Type::EnumValue.new(name: "QUERY"),
        Graphene::Type::EnumValue.new(name: "MUTATION"),
        Graphene::Type::EnumValue.new(name: "SUBSCRIPTION"),
        Graphene::Type::EnumValue.new(name: "FIELD"),
        Graphene::Type::EnumValue.new(name: "FRAGMENT_DEFINITION"),
        Graphene::Type::EnumValue.new(name: "FRAGMENT_SPREAD"),
        Graphene::Type::EnumValue.new(name: "INLINE_FRAGMENT"),
        Graphene::Type::EnumValue.new(name: "SCHEMA"),
        Graphene::Type::EnumValue.new(name: "SCALAR"),
        Graphene::Type::EnumValue.new(name: "OBJECT"),
        Graphene::Type::EnumValue.new(name: "FIELD_DEFINITION"),
        Graphene::Type::EnumValue.new(name: "ARGUMENT_DEFINITION"),
        Graphene::Type::EnumValue.new(name: "INTERFACE"),
        Graphene::Type::EnumValue.new(name: "UNION"),
        Graphene::Type::EnumValue.new(name: "ENUM"),
        Graphene::Type::EnumValue.new(name: "ENUM_VALUE"),
        Graphene::Type::EnumValue.new(name: "INPUT_OBJECT"),
        Graphene::Type::EnumValue.new(name: "INPUT_FIELD_DEFINITION")
      ]
    )

    DirectiveType = Graphene::Type::Object.new(
      typename: "__Directive",
      resolver: DirectiveResolver.new,
      fields: [
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::String.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Type::String.new
        ),
        Graphene::Schema::Field.new(
          name: "locations",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::List.new(
              of_type: Graphene::Type::NonNull.new(
                of_type: DirectiveLocationType
              )
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "args",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::List.new(
              of_type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::LateBound.new("__InputValue")
              )
            )
          )
        )
      ]
    )
  end
end