module Graphene
  module Introspection
    class TypeResolver < Graphene::Schema::Resolver
      def resolve(object : Graphene::Types::NonNull, context, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Types::List, context, field_name, argument_values)
        case field_name
        when "name"
          nil
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Types::Object, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "fields"
          object.fields
        when "interfaces"
          object.implements
        end
      end

      def resolve(object : Graphene::Types::Scalar, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        end
      end

      def resolve(object : Graphene::Types::Enum, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "enumValues"
          object.values
        end
      end

      def resolve(object : Graphene::Types::Union, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "possibleTypes"
          object.possible_types
        end
      end

      def resolve(object : Graphene::Types::Interface, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        end
      end
    end
  end
end