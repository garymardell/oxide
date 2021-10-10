module Graphql
  module DSL
    class UnionResolver < Graphql::Schema::TypeResolver
      def initialize(@interface : Graphql::DSL::Union.class)
      end

      def resolve_type(object, context)
        type = @interface.resolve_type(object, context)

        if type
          type.compile(context)
        else
          raise "type not found"
        end
      end
    end
  end
end