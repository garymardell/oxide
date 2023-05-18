module Graphene
  module Introspection
    EnumValueType = Graphene::Types::ObjectType.new(
      name: "__EnumValue",
      resolver: DefaultResolver.new,
      fields: {
        "name" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        "description" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        ),
        "isDeprecated" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::BooleanType.new
          )
        ),
        "deprecationReason" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        )
      }
    )
  end
end