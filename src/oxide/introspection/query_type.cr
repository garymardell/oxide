require "./schema_type"

module Oxide
  module Introspection
    QueryType = Oxide::Types::ObjectType.new(
      name: "__IntrospectionQuery",
      resolver: DefaultResolver.new,
      fields: {
        "__schema" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Schema")
        )
      }
    )
  end
end