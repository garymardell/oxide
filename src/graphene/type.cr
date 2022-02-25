require "./resolver"
require "./visitable"

module Graphene
  abstract class Type
    include Visitable

    abstract def description
    abstract def coerce(value)
    abstract def serialize(value)
  end
end
