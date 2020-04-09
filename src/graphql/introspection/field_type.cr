require "./type_type"
require "./input_value_type"

module Graphql
  module Introspection
    FieldType = Graphql::Type::Object.new(
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
  end
end