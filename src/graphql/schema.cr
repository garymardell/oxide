require "./type/*"
require "./schema/*"
require "./types/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object | Nil
    getter mutation : Graphql::Type::Object | Nil

    def initialize(@query = nil, @mutation = nil)
    end
  end
end
