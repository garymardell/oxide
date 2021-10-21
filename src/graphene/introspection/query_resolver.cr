module Graphene
  module Introspection
    class QueryResolver
      include Graphene::Schema::Resolvable

      def resolve(object, field_name, argument_values)
        case field_name
        when "__schema"
          schema
        end
      end
    end
  end
end