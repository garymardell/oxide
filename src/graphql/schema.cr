require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object
    getter mutation : Graphql::Type::Object | Nil

    #getter introspection : Graphql::IntrospectionSystem

    def initialize(@query, @mutation = nil)
      #@introspection = Graphql::IntrospectionSystem.new
    end
  end
end