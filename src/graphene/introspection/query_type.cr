require "./schema_type"

module Graphene
  module Introspection
    QueryType = Graphene::Type::Object.new(
      typename: "__IntrospectionQuery",
      resolver: QueryResolver.new,
      fields: [
        Graphene::Schema::Field.new(
          name: "__schema",
          type: Graphene::Type::LateBound.new("__Schema")
        )
      ]
    )
  end
end