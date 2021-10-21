module Graphene
  module Introspection
    class DirectiveResolver
      include Graphene::Schema::Resolvable

      def resolve(object, field_name, argument_values)
      end
    end
  end
end