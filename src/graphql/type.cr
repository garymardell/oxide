require "./schema/resolver"
require "./schema/visitable"

module Graphql
  abstract class Type
    include Schema::Visitable
  end
end
