module Graphene
  module Introspection
    EnumValueType = Graphene::Types::Object.new(
      name: "__EnumValue",
      resolver: EnumValueResolver.new,
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
          name: "isDeprecated",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::Boolean.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "deprecationReason",
          type: Graphene::Types::String.new
        )
      ]
    )
  end
end