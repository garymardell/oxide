require "./type"
require "./input_value"

module Graphql
  module Introspection
    Field = Graphql::Type::Object.new(
      typename: "__Field",
      resolver: FieldResolver.new,
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
          name: "args",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::List.new(
              of_type: Graphql::Type::NonNull.new(
                of_type: Graphql::Type::LateBound.new("__InputValue")
              )
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "type",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::LateBound.new("__Type")
          )
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

    IntrospectionSystem.register_type("__Field", Field)
  end
end