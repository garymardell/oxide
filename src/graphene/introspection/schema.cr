require "./query_type"

module Graphene
  module Introspection
    Schema = Graphene::Schema.new(
      query: Introspection::QueryType,
      mutation: nil
    )
  end
end