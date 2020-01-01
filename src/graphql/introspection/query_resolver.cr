module Graphql
  module Introspection
    class QueryResolver < Graphql::Schema::Resolver
      def resolve(object : Graphql::Schema, field_name, argument_values)
        case field_name
        when "__schema"
          object
        end
      end
    end
  end
end