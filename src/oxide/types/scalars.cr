  require "../type"

module Oxide
  module Types
    abstract class ScalarType < Type
      def kind
        "SCALAR"
      end

      def input_type? : Bool
        true
      end

      def output_type? : Bool
        true
      end
    end

    class IdType < ScalarType
      def name
        "ID"
      end

      def description
        "Represents a unique identifier that is Base64 obfuscated. It is often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"VXNlci0xMA==\"`) or integer (such as `4`) input value will be accepted as an ID."
      end

      def coerce(value : String) : JSON::Any::Type
        value
      end

      def coerce(value : Int) : JSON::Any::Type
        value.to_s
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        value.as_s
      end

      def coerce(value : Oxide::Language::Nodes::StringValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Could not coerce id")
      end

      def serialize(value) : SerializedOutput
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

      def coerce(value : JSON::Any) : JSON::Any::Type
        value.as_s
      end

      def coerce(value : String) : JSON::Any::Type
        value
      end

      def coerce(value : Oxide::Language::Nodes::StringValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("String cannot represent a non-string value")
      end

      def serialize(value) : SerializedOutput
        return value if value.nil?

        if value.responds_to?(:to_s)
          value.to_s
        elsif value.responds_to?(:as_s)
          value.as_s
        else
          raise InputCoercionError.new("Could not coerce value to String")
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

      def coerce(value : Int32) : JSON::Any::Type
        value.to_i64
      end

      def coerce(value : Int64) : JSON::Any::Type
        value
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        value.as_i64
      end

      def coerce(value : Oxide::Language::Nodes::IntValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Int cannot represent a non-interger value")
      end

      def serialize(value) : SerializedOutput
        return value if value.nil?

        case value
        when String, Int
          value.to_i32
        when Float
          if value % 1 == 0
            value.to_i32
          else
            raise SerializationError.new("#{value} cannot be serialized as Int")
          end
        else
          if value.responds_to?(:as_i)
            value.as_i
          else
            raise SerializationError.new("#{value} cannot be serialized as Int")
          end
        end
      rescue ex : Exception
        raise SerializationError.new("#{value} cannot be serialized as Int")
      end
    end

    class FloatType < ScalarType
      def name
        "Float"
      end

      def description
        "Represents signed double-precision fractional values as specified by [IEEE 754](https://en.wikipedia.org/wiki/IEEE_floating_point)."
      end

      def coerce(value : Float32) : JSON::Any::Type
        value.to_f64
      end

      def coerce(value : Float64) : JSON::Any::Type
        value
      end

      def coerce(value : Int32) : JSON::Any::Type
        value.to_f64
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        value.as_f
      end

      def coerce(value : Oxide::Language::Nodes::FloatValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Could not coerce value to Float")
      end

      def serialize(value) : SerializedOutput
        if value.responds_to?(:to_f32)
          value.to_f32
        else
          raise SerializationError.new("Cannot serialize value to float")
        end
      end
    end

    class BooleanType < ScalarType
      def name
        "Boolean"
      end

      def description
        "Represents `true` or `false` values."
      end

      def coerce(value : Bool) : JSON::Any::Type
        value
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        value.as_bool
      end

      def coerce(value : Oxide::Language::Nodes::BooleanValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Can't coerce non boolean value from #{value.class.name}")
      end

      def serialize(value) : SerializedOutput
        coerce(value)
      end
    end

    class DateType < ScalarType
      def name
        "Date"
      end

      def description
        "Represents a ISO8601 date value."
      end

      def coerce(value : Time) : JSON::Any::Type
        value.to_s("%F")
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        Time.parse_utc(value.to_s, "%F").to_s("%F")
      end

      def coerce(value : Oxide::Language::Nodes::StringValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Can't coerce non date value from #{value.class.name}")
      end

      def serialize(value) : SerializedOutput
        coerce(value)
      end
    end

    class DateTimeType < ScalarType
      def name
        "DateTime"
      end

      def description
        "Represents a ISO8601 datetime value."
      end

      def coerce(value : Time) : JSON::Any::Type
        value.to_rfc3339
      end

      def coerce(value : JSON::Any) : JSON::Any::Type
        Time.parse_rfc3339(value.to_s).to_rfc3339
      end

      def coerce(value : Oxide::Language::Nodes::StringValue) : JSON::Any::Type
        value.value
      end

      def coerce(value) : JSON::Any::Type
        raise InputCoercionError.new("Can't coerce non datetime value from #{value.class.name}")
      end

      def serialize(value) : SerializedOutput
        coerce(value)
      end
    end

    class CustomScalarType < ScalarType
      getter name : String
      getter description : String?
      getter specified_by_url : String?
      getter applied_directives : Array(AppliedDirective)

      def initialize(@name : String, @description : String? = nil, @specified_by_url : String? = nil, @applied_directives = [] of AppliedDirective)
      end

      def coerce(value) : JSON::Any::Type
      end

      def serialize(value) : SerializedOutput
      end
    end
  end
end
