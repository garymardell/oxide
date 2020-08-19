module Graphql
  module Introspection
    class TypeResolver
      include Graphql::Schema::Resolvable

      def resolve(object : Graphql::Type::NonNull, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphql::Type::List, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphql::Type::Object, field_name, argument_values)
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

      def resolve(object : Graphql::Type::Scalar, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        end
      end

      def resolve(object : Graphql::Type::Enum, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          object.kind
        when "enumValues"
          object.values
        end
      end

      def resolve(object : Graphql::Type::Union, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          object.kind
        when "possibleTypes"
          object.possible_types
        end
      end

      def resolve(object : Graphql::Type::Interface, field_name, argument_values)
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