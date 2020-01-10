module Graphql
  module Introspection
    EnumValue = Graphql::Type::Object.new(
      typename: "__EnumValue",
      resolver: EnumValueResolver.new,
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
          name: "isDeprecated",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::Boolean.new
          )
        ),
        Graphql::Schema::Field.new(
          name: "deprecationReason",
          type: Graphql::Type::String.new
        )
      ]
    )

    IntrospectionSystem.register_type("__EnumValue", EnumValue)
  end
end