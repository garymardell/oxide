module Graphql
  class Schema
    abstract class Resolver
      abstract def resolve(object, field_name, argument_values)

      def resolve(object, field_name, argument_values)
      end
    end
  end
end
