module Graphql
  class Schema
    abstract class Resolver
      abstract def resolve(object, field_name)

      def resolve(object, field_name)
      end
    end

    class ScalarResolver < Resolver
      def resolve(object, field_name)
        object
      end
    end
  end
end
