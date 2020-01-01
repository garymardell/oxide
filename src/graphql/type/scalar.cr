require "../type"

module Graphql
  class Type
    abstract class Scalar < Type
      abstract def coerce(value)
    end

    class Id < Scalar
      def coerce(value)
        value.try &.to_s
      end
    end

    class String < Scalar
      def coerce(value)
        value.try &.to_s
      end
    end

    class Int < Scalar
      def coerce(value)
        value.try &.to_i32
      end
    end

    class Float < Scalar
      def coerce(value)
        value.try &.to_f32
      end
    end

    class Boolean < Scalar
      def coerce(value)
        !!value
      end
    end
  end
end
