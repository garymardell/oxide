module Graphql
  module DSL
    class InterfaceResolver < Graphql::Schema::TypeResolver
      def initialize(@interface : Graphql::DSL::Interface.class)
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