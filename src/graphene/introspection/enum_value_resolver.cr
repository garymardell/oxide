module Graphene
  module Introspection
    class EnumValueResolver < Graphene::Resolver
      def resolve(object : Graphene::Types::EnumValue, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "isDeprecated"
          object.deprecated?
        when "deprecationReason"
          object.deprecation_reason
        end
      end
    end
  end
end