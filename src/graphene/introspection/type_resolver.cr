module Graphene
  module Introspection
    class TypeResolver
      include Graphene::Schema::Resolvable

      def resolve(object : Graphene::Type::NonNull, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Type::List, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Type::Object, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          object.kind
        when "fields"
          object.fields
        when "interfaces"
          object.implements
        end
      end

      def resolve(object : Graphene::Type::Scalar, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        end
      end

      def resolve(object : Graphene::Type::Enum, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          object.kind
        when "enumValues"
          object.values
        end
      end

      def resolve(object : Graphene::Type::Union, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          object.kind
        when "possibleTypes"
          object.possible_types
        end
      end

      def resolve(object : Graphene::Type::Interface, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        end
      end
    end
  end
end