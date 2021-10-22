module Graphene
  module Introspection
    class EnumValueResolver < Graphene::Schema::Resolver
      def resolve(object : Graphene::Type::EnumValue, context, field_name, argument_values)
        case field_name
        when "name"
          object.name
        when "description"
          ""
        when "isDeprecated"
          false
        when "deprecationReason"
        end
      end
    end
  end
end