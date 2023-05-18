require "./schema_type"

module Graphene
  module Introspection
    QueryType = Graphene::Types::ObjectType.new(
      name: "__IntrospectionQuery",
      resolver: DefaultResolver.new,
      fields: {
        "__schema" => Graphene::Field.new(
          type: Graphene::Types::LateBoundType.new("__Schema")
        )
      }
    )
  end
end