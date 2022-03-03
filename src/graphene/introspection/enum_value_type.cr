module Graphene
  module Introspection
    EnumValueType = Graphene::Types::ObjectType.new(
      name: "__EnumValue",
      resolver: EnumValueResolver.new,
      fields: {
        "name" => Graphene::Field.new(
          name: "name",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        "description" => Graphene::Field.new(
          name: "description",
          type: Graphene::Types::StringType.new
        ),
        "isDeprecated" => Graphene::Field.new(
          name: "isDeprecated",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::BooleanType.new
          )
        ),
        "deprecationReason" => Graphene::Field.new(
          name: "deprecationReason",
          type: Graphene::Types::StringType.new
        )
      }
    )
  end
end