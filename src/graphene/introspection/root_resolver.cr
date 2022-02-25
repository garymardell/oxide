module Graphene
  module Introspection
    class RootResolver < Graphene::Resolver
      def resolve(object, context, field_name, argument_values)
        context.schema
      end
    end
  end
end