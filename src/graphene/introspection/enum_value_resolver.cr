module Graphene
  module Introspection
    class EnumValueResolver
      include Graphene::Schema::Resolvable

      def resolve(object : Graphene::Type::EnumValue, field_name, argument_values)
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