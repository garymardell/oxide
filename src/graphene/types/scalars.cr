  require "../type"

module Graphene
  module Types
    abstract class ScalarType < Type
      def kind
        "SCALAR"
      end
    end

    class IdType < ScalarType
      def name
        "ID"
      end

      def description
        "Represents a unique identifier that is Base64 obfuscated. It is often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"VXNlci0xMA==\"`) or integer (such as `4`) input value will be accepted as an ID."
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

      def serialize(value)
        coerce(value)
      end
    end

    class StringType < ScalarType
      def name
        "String"
      end

      def description
        "Represents textual data as UTF-8 character sequences. This type is most often used by GraphQL to represent free-form human-readable text."
      end

      def coerce(value : String)
        value
      end

      def coerce(value)
        raise "String cannot represent a non-string value"
      end

      def serialize(value)
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

    class IntType < ScalarType
      def name
        "Int"
      end

      def description
        "Represents non-fractional signed whole numeric values. Int can represent values between -(2^31) and 2^31 - 1."
      end

      def coerce(value : Int32)
        value
      end

      def coerce(value)
        raise "Int cannot represent a non-interger value"
      end

      def serialize(value)
        return value if value.nil?

        if value.responds_to?(:to_i32)
          value.to_i32
        elsif value.responds_to?(:as_i)
          value.as_i
        else
          raise "Could not serialize value to Int"
        end
      end
    end

    class FloatType < ScalarType
      def name
        "Float"
      end

      def description
        "Represents signed double-precision fractional values as specified by [IEEE 754](https://en.wikipedia.org/wiki/IEEE_floating_point)."
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

      def serialize(value)
        coerce(value)
      end
    end

    class BooleanType < ScalarType
      def name
        "Boolean"
      end

      def description
        "Represents `true` or `false` values."
      end

      def coerce(value)
        return value if value.nil?

        if value.responds_to?(:as_bool)
          value.as_bool
        else
          !!value
        end
      end

      def serialize(value)
        coerce(value)
      end
    end

    class CustomScalarType < ScalarType
      getter name : String
      getter description : String?
      getter specified_by_url : String?

      def initialize(@name : String, @description : String? = nil, @specified_by_url : String? = nil)
      end

      def coerce(value)
      end

      def serialize(value)
        value
      end
    end
  end
end
