module Graphene
  class Schema
    module Resolvable
      property schema : Graphene::Schema?

      abstract def resolve(object, context, field_name, argument_values)

      def resolve(object, context, field_name, argument_values)
        nil
      end
    end
  end
end