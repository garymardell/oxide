require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object | Nil
    getter mutation : Graphql::Type::Object | Nil
    getter types : Hash(String, Graphql::Type)

    def initialize(@query = nil, @mutation = nil)
      @types = {} of String => Graphql::Type
    end

    def possible_types(type)
      PossibleTypes.new(self).possible_types(type)
    end

    def register_type(typename, type)
      @types[typename] = type
    end
  end
end