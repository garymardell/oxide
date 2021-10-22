require "./schema_type"

module Graphene
  module Introspection
    QueryType = Graphene::Type::Object.new(
      name: "__IntrospectionQuery",
      fields: [
        Graphene::Schema::Field.new(
          name: "__schema",
          type: Graphene::Type::LateBound.new("__Schema")
        )
      ]
    )
  end
end