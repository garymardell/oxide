module Graphql
  module Introspection
    class DirectiveResolver
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
      end
    end
  end
end