require "../../src/graphql"
require "./models/*"
require "./types/*"

class DummySchema < Graphql::DSL::Schema
  query(Types::QueryType)
end