require "./input_value"

module Graphql
  module Introspection
    DirectiveLocation = Graphql::Type::Enum.new(
      values: [
        Graphql::Type::EnumValue.new(name: "QUERY"),
        Graphql::Type::EnumValue.new(name: "MUTATION"),
        Graphql::Type::EnumValue.new(name: "SUBSCRIPTION"),
        Graphql::Type::EnumValue.new(name: "FIELD"),
        Graphql::Type::EnumValue.new(name: "FRAGMENT_DEFINITION"),
        Graphql::Type::EnumValue.new(name: "FRAGMENT_SPREAD"),
        Graphql::Type::EnumValue.new(name: "INLINE_FRAGMENT"),
        Graphql::Type::EnumValue.new(name: "SCHEMA"),
        Graphql::Type::EnumValue.new(name: "SCALAR"),
        Graphql::Type::EnumValue.new(name: "OBJECT"),
        Graphql::Type::EnumValue.new(name: "FIELD_DEFINITION"),
        Graphql::Type::EnumValue.new(name: "ARGUMENT_DEFINITION"),
        Graphql::Type::EnumValue.new(name: "INTERFACE"),
        Graphql::Type::EnumValue.new(name: "UNION"),
        Graphql::Type::EnumValue.new(name: "ENUM"),
        Graphql::Type::EnumValue.new(name: "ENUM_VALUE"),
        Graphql::Type::EnumValue.new(name: "INPUT_OBJECT"),
        Graphql::Type::EnumValue.new(name: "INPUT_FIELD_DEFINITION")
      ]
    )

    Directive = Graphql::Type::Object.new(
      typename: "__Directive",
      resolver: DirectiveResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "name",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::String.new
          )
        ),
        Graphql::Schema::Field.new(
          name: "description",
          type: Graphql::Type::String.new
        ),
        Graphql::Schema::Field.new(
          name: "locations",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::List.new(
              of_type: Graphql::Type::NonNull.new(
                of_type: DirectiveLocation
              )
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "args",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::List.new(
              of_type: Graphql::Type::NonNull.new(
                of_type: Graphql::Type::LateBound.new("__InputValue")
              )
            )
          )
        )
      ]
    )

    IntrospectionSystem.register_type("__Directive", Directive)
  end
end