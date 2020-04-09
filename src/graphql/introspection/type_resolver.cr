module Graphql
  module Introspection
    class TypeResolver
      include Graphql::Schema::Resolvable

      def resolve(object : Graphql::Type::NonNull, field_name, argument_values)
        case field_name
        when "ofType"
          object.of_type
        end
      end

      def resolve(object : Graphql::Type::Object, field_name, argument_values)
        case field_name
        when "name"
          object.typename
        when "kind"
          "OBJECT"
        end
      end
    end
  end
end