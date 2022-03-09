module Graphene
  module Introspection
    class InputValueResolver < Graphene::Resolver
      def resolve(object : ArgumentInfo, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "type"
          object.argument.type
        end
      end
    end
  end
end