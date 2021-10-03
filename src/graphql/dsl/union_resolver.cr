module Graphql
  module DSL
    class UnionResolver < Graphql::Schema::TypeResolver
      def initialize(@interface : Graphql::DSL::Union.class)
      end

      def resolve_type(object)
        type = @interface.resolve_type(object)

        if type
          type.compile
        else
          raise "type not found"
        end
      end
    end
  end
end