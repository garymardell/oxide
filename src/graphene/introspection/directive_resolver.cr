module Graphene
  module Introspection
    class DirectiveResolver < Graphene::Schema::Resolver
      def resolve(object, context, field_name, argument_values)
      end
    end
  end
end