require "./schema/resolver"

module Graphql
  abstract class Type
    getter resolver : Schema::Resolver?
  end
end
