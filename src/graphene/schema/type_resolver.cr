module Graphene
  class Schema
    abstract class TypeResolver
      def resolve_type(object, context)
        raise "Could not resolve union type"
      end
    end
  end
end