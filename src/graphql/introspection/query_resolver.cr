module Graphql
  module Introspection
    class QueryResolver
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
        case field_name
        when "__schema"
          schema
        end
      end
    end
  end
end