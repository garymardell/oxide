require "./schema/resolver"
require "./schema/visitable"

module Graphql
  abstract class Type
    include Schema::Visitable

    getter resolver : Schema::Resolvable?
  end
end
