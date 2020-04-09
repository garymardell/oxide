module Graphql
  module Introspection
    class QueryResolver
      include Graphql::Schema::Resolvable

      def resolve(object : Graphql::Schema, field_name, argument_values)
        case field_name
        when "__schema"
          object
        end
      end
    end
  end
end