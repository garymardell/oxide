require "./schema/resolver"
require "./schema/visitable"

module Graphene
  abstract class Type
    include Schema::Visitable
  end
end
