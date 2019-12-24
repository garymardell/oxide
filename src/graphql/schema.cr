require "./schema/*"
require "./types/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Schema::Object | Nil
    getter mutation : Graphql::Schema::Object | Nil

    def initialize(@query = nil, @mutation = nil)
    end
  end
end
