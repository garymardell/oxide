module Graphene
  module Introspection
    class InputValueResolver < Graphene::Resolver
      def resolve(object : Graphene::Argument, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "type"
          object.type
        end
      end
    end
  end
end