module Graphene
  module Introspection
    class QueryResolver < Graphene::Resolver
      def resolve(object, context, field_name, argument_values)
        case field_name
        when "__schema"
          context.schema
        end
      end
    end
  end
end