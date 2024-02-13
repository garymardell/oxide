require "./schema_type"

module Oxide
  module Introspection
    QueryType = Oxide::Types::ObjectType.new(
      name: "__IntrospectionQuery",
      fields: {
        "__schema" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Schema"),
          resolve: ->(query : Query, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            info.schema
          }
        )
      }
    )
  end
end