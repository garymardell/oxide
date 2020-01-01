require "../type"

module Graphql
  class Type
    abstract class Scalar < Type
    end

    class Id < Scalar
    end

    class String < Scalar
    end

    class Int < Scalar
    end

    class Float < Scalar
    end

    class Boolean < Scalar
    end
  end
end
