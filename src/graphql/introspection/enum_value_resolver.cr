module Graphql
  module Introspection
    class EnumValueResolver
      include Graphql::Schema::Resolvable

      def resolve(object : Graphql::Type::EnumValue, field_name, argument_values)
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