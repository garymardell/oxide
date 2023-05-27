require "./resolver"
require "./visitable"

module Graphene
  abstract class Type
    include Visitable
    include Resolvable

    abstract def description
    abstract def coerce(value) : CoercedInput
    abstract def serialize(value)
  end
end
