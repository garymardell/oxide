require "./schema_type"

module Graphene
  module Introspection
    QueryType = Graphene::Types::Object.new(
      name: "__IntrospectionQuery",
      resolver: QueryResolver.new,
      fields: [
        Graphene::Field.new(
          name: "__schema",
          type: Graphene::Types::LateBound.new("__Schema")
        )
      ]
    )
  end
end