module Graphene
  module Introspection
    EnumValueType = Graphene::Type::Object.new(
      typename: "__EnumValue",
      resolver: EnumValueResolver.new,
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
          name: "isDeprecated",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::Boolean.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "deprecationReason",
          type: Graphene::Type::String.new
        )
      ]
    )
  end
end