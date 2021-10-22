module Graphene
  module Introspection
    class QueryResolver < Graphene::Schema::Resolver
      def resolve(object, context, field_name, argument_values)
        case field_name
        when "__schema"
          schema
        end
      end
    end
  end
end