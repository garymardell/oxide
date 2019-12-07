module Graphql
  class Schema
    abstract class Resolver
      abstract def resolve(object, field_name)

      def resolve(object, field_name)
      end
    end
  end
end
