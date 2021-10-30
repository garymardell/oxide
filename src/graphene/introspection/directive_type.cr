require "./input_value_type"

module Graphene
  module Introspection
    DirectiveLocationType = Graphene::Types::Enum.new(
      name: "__DirectiveLocation",
      values: [
        Graphene::Types::EnumValue.new(name: "QUERY"),
        Graphene::Types::EnumValue.new(name: "MUTATION"),
        Graphene::Types::EnumValue.new(name: "SUBSCRIPTION"),
        Graphene::Types::EnumValue.new(name: "FIELD"),
        Graphene::Types::EnumValue.new(name: "FRAGMENT_DEFINITION"),
        Graphene::Types::EnumValue.new(name: "FRAGMENT_SPREAD"),
        Graphene::Types::EnumValue.new(name: "INLINE_FRAGMENT"),
        Graphene::Types::EnumValue.new(name: "SCHEMA"),
        Graphene::Types::EnumValue.new(name: "SCALAR"),
        Graphene::Types::EnumValue.new(name: "OBJECT"),
        Graphene::Types::EnumValue.new(name: "FIELD_DEFINITION"),
        Graphene::Types::EnumValue.new(name: "ARGUMENT_DEFINITION"),
        Graphene::Types::EnumValue.new(name: "INTERFACE"),
        Graphene::Types::EnumValue.new(name: "UNION"),
        Graphene::Types::EnumValue.new(name: "ENUM"),
        Graphene::Types::EnumValue.new(name: "ENUM_VALUE"),
        Graphene::Types::EnumValue.new(name: "INPUT_OBJECT"),
        Graphene::Types::EnumValue.new(name: "INPUT_FIELD_DEFINITION")
      ]
    )

    DirectiveType = Graphene::Types::Object.new(
      name: "__Directive",
      fields: [
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::String.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Types::String.new
        ),
        Graphene::Schema::Field.new(
          name: "locations",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::List.new(
              of_type: Graphene::Types::NonNull.new(
                of_type: DirectiveLocationType
              )
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "args",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::List.new(
              of_type: Graphene::Types::NonNull.new(
                of_type: Graphene::Types::LateBound.new("__InputValue")
              )
            )
          )
        )
      ]
    )
  end
end