module Graphene
  module Introspection
    class QueryResolver < Graphene::Resolver
      def resolve(object, field_name, argument_values, context, resolution_info)
        case field_name
        when "__schema"
          resolution_info.schema
        end
      end
    end
  end
end