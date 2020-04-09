module Graphql
  module Introspection
    class InputValueResolver
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
      end
    end
  end
end