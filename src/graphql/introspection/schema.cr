require "./type"
require "./directive"

module Graphql
  module Introspection
    Schema = Graphql::Type::Object.new(
      typename: "__Type",
      resolver: SchemaResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "types",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::List.new(
              of_type: Graphql::Type::NonNull.new(
                of_type: Graphql::Type::LateBound.new("__Type")
              )
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "queryType",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::LateBound.new("__Type")
          )
        ),
        Graphql::Schema::Field.new(
          name: "mutationType",
          type: Graphql::Type::LateBound.new("__Type")
        ),
        Graphql::Schema::Field.new(
          name: "subscriptionType",
          type: Graphql::Type::LateBound.new("__Type")
        ),
        Graphql::Schema::Field.new(
          name: "directives",
          type: Graphql::Type::NonNull.new(
            of_type: Graphql::Type::List.new(
              of_type: Graphql::Type::NonNull.new(
                of_type: Graphql::Type::LateBound.new("__Directive")
              )
            )
          )
        )
      ]
    )
  end
end
