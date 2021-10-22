require "./resolvable"

module Graphene
  class Schema
    abstract class Resolver
      include Resolvable
    end

    class NullResolver < Resolver
      def resolve(object, context, field_name, argument_values)
        nil
      end
    end
  end
end
