module Graphql
  module Introspection
    class FieldResolver
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
      end
    end
  end
end