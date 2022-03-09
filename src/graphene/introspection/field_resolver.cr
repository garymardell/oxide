module Graphene
  module Introspection
    class FieldResolver  < Graphene::Resolver
      def resolve(object : Tuple(String, Graphene::Field), field_name, argument_values, context, resolution_info)
        name, field = object

        case field_name
        when "name"
          name
        when "description"
          nil
        when "args"
          field.arguments.map do |name, argument|
            {name, argument}
          end
        when "type"
          field.type
        when "isDeprecated"
          field.deprecated?
        when "deprecationReason"
          field.deprecation_reason
        end
      end
    end
  end
end