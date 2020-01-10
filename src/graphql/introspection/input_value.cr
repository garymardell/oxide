require "./type"

module Graphql
  module Introspection
    InputValue = Graphql::Type::Object.new(
      typename: "__InputValue",
      resolver: InputValueResolver.new,
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
          name: "type",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::LateBound.new("__Type")
          )
        ),
        Graphql::Schema::Field.new(
          name: "defaultValue",
          type: Graphql::Type::String.new
        )
      ]
    )

    IntrospectionSystem.register_type("__InputValue", InputValue)
  end
end