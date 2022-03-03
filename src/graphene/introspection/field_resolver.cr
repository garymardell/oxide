module Graphene
  module Introspection
    class FieldResolver  < Graphene::Resolver
      def resolve(object : Graphene::Field, field_name, argument_values, context, resolution_info)
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
          object.deprecated?
        when "deprecationReason"
          object.deprecation_reason
        end
      end
    end
  end
end