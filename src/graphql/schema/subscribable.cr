module Graphql
  class Schema
    module Subscribable
      property schema : Graphql::Schema?

      abstract def subscribe(object, context, field_name, argument_values)

      def subscribe(object, context, field_name, argument_values)
        nil
      end
    end
  end
end