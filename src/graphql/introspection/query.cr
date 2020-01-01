require "./schema"

module Graphql
  module Introspection
    Query = Graphql::Type::Object.new(
      typename: "__IntrospectionQuery",
      resolver: QueryResolver.new
    )

    Query.add_field(Graphql::Schema::Field.new(
      name: "__schema",
      type: Introspection::Schema
    ))
  end
end