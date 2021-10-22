module Graphene
  module Introspection
    class TypeResolver < Graphene::Schema::Resolver
      def resolve(object : Graphene::Type::NonNull, context, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Type::List, context, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Type::Object, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        when "fields"
          object.fields
        when "interfaces"
          object.implements
        end
      end

      def resolve(object : Graphene::Type::Scalar, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        end
      end

      def resolve(object : Graphene::Type::Enum, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        when "enumValues"
          object.values
        end
      end

      def resolve(object : Graphene::Type::Union, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "kind"
          object.kind
        when "possibleTypes"
          object.possible_types
        end
      end

      def resolve(object : Graphene::Type::Interface, context, field_name, argument_values)
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