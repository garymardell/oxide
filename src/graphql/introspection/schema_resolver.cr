module Graphql
  module Introspection
    class SchemaResolver < Graphql::Schema::Resolver
      def resolve(object, field_name, argument_values)
        case field_name
        when "types"
          schema.not_nil!.types
        when "queryType"
          schema.not_nil!.query
        when "mutationType"
          schema.not_nil!.mutation
        when "subscriptionType"
          nil # TODO: Support subscriptions
        end
      end
    end
  end
end