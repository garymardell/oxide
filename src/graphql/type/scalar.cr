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
        elsif value.responds_to?(:as_s)
          value.as_s
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
        elsif value.responds_to?(:as_s)
          value.as_s
        else
          raise "Could not coerce value to String"
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
        elsif value.responds_to?(:as_i)
          value.as_i
        else
          raise "Could not coerce value to Int"
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
        elsif value.responds_to?(:as_f)
          value.as_f
        else
          raise "Could not coerce value to Float"
        end
      end
    end

    class Boolean < Scalar
      def name
        "Boolean"
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:as_bool)
          value.as_bool
        else
          !!value
        end
      end
    end
  end
end
