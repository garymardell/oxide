  require "../type"

module Graphene
  module Types
    abstract class ScalarType < Type
      def kind
        "SCALAR"
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          description
        when "kind"
          kind
        when "specifiedByURL"
          if self.responds_to?(:specified_by_url)
            self.specified_by_url
          end
        end
      end
    end

    class IdType < ScalarType
      def name
        "ID"
      end

      def description
        "Represents a unique identifier that is Base64 obfuscated. It is often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"VXNlci0xMA==\"`) or integer (such as `4`) input value will be accepted as an ID."
      end

      def coerce(value : String)  : Execution::Runtime::VariableType
        value
      end

      def coerce(value : Int32)  : Execution::Runtime::VariableType
        value.to_s
      end

      def coerce(value : JSON::Any)  : Execution::Runtime::VariableType
        value.as_s
      end

      def coerce(value)  : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Could not coerce id")
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

      def coerce(value : JSON::Any) : Execution::Runtime::VariableType
        value.as_s
      end

      def coerce(value : String) : Execution::Runtime::VariableType
        value
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("String cannot represent a non-string value")
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

      def coerce(value : Int32) : Execution::Runtime::VariableType
        value
      end

      def coerce(value : Int64) : Execution::Runtime::VariableType
        value.to_i32
      rescue e : OverflowError
        raise Execution::Runtime::InputCoercionError.new("Cannot be converted to Int32")
      end

      def coerce(value : JSON::Any) : Execution::Runtime::VariableType
        value.as_i
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Int cannot represent a non-interger value")
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

      def coerce(value : Float32)  : Execution::Runtime::VariableType
        value.to_f64
      end

      def coerce(value : Float64)  : Execution::Runtime::VariableType
        value
      end

      def coerce(value : Int32)  : Execution::Runtime::VariableType
        value.to_f64
      end

      def coerce(value : JSON::Any) : Execution::Runtime::VariableType
        value.as_f
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Could not coerce value to Float")
      end

      def serialize(value) : Execution::Runtime::VariableType
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

      def coerce(value : Bool) : Execution::Runtime::VariableType
        value
      end

      def coerce(value : JSON::Any)  : Execution::Runtime::VariableType
        value.as_bool
      end

      def coerce(value) : Execution::Runtime::VariableType
        raise Execution::Runtime::InputCoercionError.new("Can't coerce non boolean value from #{value.class.name}")
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

      def coerce(value) : Execution::Runtime::VariableType
      end

      def serialize(value)
        value
      end
    end
  end
end
