  require "../type"

module Graphql
  class Type
    abstract class Scalar < Type
      abstract def coerce(value)

      def kind
        "SCALAR"
      end
    end

    class Id < Scalar
      def name
        "ID"
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:to_s)
          value.to_s
        else
          raise "Could not coerce value to Id"
        end
      end
    end

    class String < Scalar
      def name
        "String"
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:to_s)
          value.to_s
        else
          raise "Could not coerce value to Id"
        end
      end
    end

    class Int < Scalar
      def name
        "Int"
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:to_i32)
          value.to_i32
        else
          raise "Could not coerce value to Id"
        end
      end
    end

    class Float < Scalar
      def name
        "Float"
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:to_f32)
          value.to_f32
        else
          raise "Could not coerce value to Id"
        end
      end
    end

    class Boolean < Scalar
      def name
        "Boolean"
      end

      def coerce(value)
        return value if value.nil?

        !!value
      end
    end
  end
end
