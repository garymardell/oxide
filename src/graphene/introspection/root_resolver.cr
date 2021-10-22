module Graphene
  module Introspection
    class RootResolver < Graphene::Schema::Resolver
      def resolve(object, context, field_name, argument_values)
        schema
      end
    end
  end
end