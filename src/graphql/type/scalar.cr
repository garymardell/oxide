require "../type"

module Graphql
  class Type
    abstract class Scalar < Type
    end

    class Id < Scalar
    end

    class String < Scalar
    end
  end
end
