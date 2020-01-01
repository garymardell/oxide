require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object | Nil
    getter mutation : Graphql::Type::Object | Nil

    def initialize(@query = nil, @mutation = nil)
    end

    def possible_types(type)
      PossibleTypes.new(self).possible_types(type)
    end
  end
end
