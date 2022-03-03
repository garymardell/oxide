module Graphene
  module Introspection
    class SchemaResolver < Graphene::Resolver
      def resolve(object, field_name, argument_values, context, resolution_info)
        case field_name
        when "types"
          resolution_info.schema.types
        when "queryType"
          resolution_info.schema.query
        when "mutationType"
          resolution_info.schema.mutation
        when "subscriptionType"
          nil # TODO: Support subscriptions
        when "directives"
          [] of Graphene::Type # TODO: support directives
        end
      end
    end
  end
end