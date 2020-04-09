require "./query_type"

module Graphql
  module Introspection
    Schema = Graphql::Schema.new(
      query: Introspection::QueryType,
      mutation: nil
    )
  end
end