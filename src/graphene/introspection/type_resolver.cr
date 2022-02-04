module Graphene
  module Introspection
    class TypeResolver < Graphene::Schema::Resolver
      def resolve(object : Graphene::Types::NonNull, context, field_name, argument_values)
        case field_name
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphene::Types::List, context, field_name, argument_values)
        case field_name
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
          if argument_values["includeDeprecated"]?
            object.fields
          else
            object.fields.reject(&.deprecated?)
          end
        when "interfaces"
          object.interfaces
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
        when "specifiedByURL"
          if object.responds_to?(:specified_by_url)
            object.specified_by_url
          end
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
          if argument_values["includeDeprecated"]?
            object.values
          else
            object.values.reject(&.deprecated?)
          end
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
        when "fields"
          if argument_values["includeDeprecated"]?
            object.fields
          else
            object.fields.reject(&.deprecated?)
          end
        when "interfaces"
          object.interfaces
        when "possibleTypes"
          schema.not_nil!.type_map.each_with_object([] of Graphene::Type) do |(_, type), memo|
            if type.responds_to?(:interfaces) && type.interfaces.includes?(object)
              memo << type
            end
          end
        end
      end

      def resolve(object : Graphene::Types::LateBound, context, field_name, argument_values)
        unwrapped_type = get_type(object.typename)

        resolve(unwrapped_type, context, field_name, argument_values)
      end

      private def get_type(typename)
        case typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
          IntrospectionSystem.types[typename]
        else
          schema.not_nil!.get_type(typename)
        end
      end
    end
  end
end