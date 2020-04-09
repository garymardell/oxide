require "./schema_type"

module Graphql
  module Introspection
    QueryType = Graphql::Type::Object.new(
      typename: "__IntrospectionQuery",
      resolver: QueryResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "__schema",
          type: Graphql::Type::LateBound.new("__Schema")
        )
      ]
    )
  end
end