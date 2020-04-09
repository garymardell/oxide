require "./type_type"

module Graphql
  module Introspection
    InputValueType = Graphql::Type::Object.new(
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
  end
end