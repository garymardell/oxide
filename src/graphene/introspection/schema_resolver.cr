module Graphene
  module Introspection
    class SchemaResolver < Graphene::Resolver
      def resolve(object, context, field_name, argument_values)
        case field_name
        when "types"
          context.schema.types
        when "queryType"
          context.schema.query
        when "mutationType"
          context.schema.mutation
        when "subscriptionType"
          nil # TODO: Support subscriptions
        when "directives"
          [] of Graphene::Type # TODO: support directives
        end
      end
    end
  end
end