module Graphene
  module Introspection
    class FieldResolver  < Graphene::Schema::Resolver
      def resolve(object : Graphene::Schema::Field, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          nil
        when "args"
          object.arguments
        when "type"
          object.type
        when "isDeprecated"
          false # TODO: Support deprecated flag
        when "deprecationReason"
          nil # TODO: Support deprecated reason
        end
      end
    end
  end
end