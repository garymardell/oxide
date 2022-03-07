require "./input_value_type"

module Graphene
  module Introspection
    DirectiveLocationType = Graphene::Types::EnumType.new(
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

    DirectiveType = Graphene::Types::ObjectType.new(
      name: "__Directive",
      resolver: DirectiveResolver.new,
      fields: {
        "name" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        "description" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        ),
        "locations" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: DirectiveLocationType
              )
            )
          )
        ),
        "args" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__InputValue")
              )
            )
          )
        )
      }
    )
  end
end