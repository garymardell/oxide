module Graphene
  module Introspection
    class SchemaResolver < Graphene::Schema::Resolver
      def resolve(object, context, field_name, argument_values)
        case field_name
        when "types"
          schema.not_nil!.types
        when "queryType"
          schema.not_nil!.query
        when "mutationType"
          schema.not_nil!.mutation
        when "subscriptionType"
          nil # TODO: Support subscriptions
        when "directives"
          [] of Graphene::Type # TODO: support directives
        end
      end
    end
  end
end