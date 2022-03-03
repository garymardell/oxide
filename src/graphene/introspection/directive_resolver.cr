module Graphene
  module Introspection
    class DirectiveResolver < Graphene::Resolver
      def resolve(object, field_name, argument_values, context, resolution_info)
      end
    end
  end
end