module Graphene
  module Introspection
    EnumValueType = Graphene::Types::Object.new(
      name: "__EnumValue",
      resolver: EnumValueResolver.new,
      fields: [
        Graphene::Field.new(
          name: "name",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::String.new
          )
        ),
        Graphene::Field.new(
          name: "description",
          type: Graphene::Types::String.new
        ),
        Graphene::Field.new(
          name: "isDeprecated",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::Boolean.new
          )
        ),
        Graphene::Field.new(
          name: "deprecationReason",
          type: Graphene::Types::String.new
        )
      ]
    )
  end
end