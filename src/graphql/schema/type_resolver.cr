module Graphql
  class Schema
    abstract class TypeResolver
      def resolve_type(object)
        raise "Could not resolve union type"
      end
    end
  end
end