module Graphene
  module Introspection
    class InputValueResolver < Graphene::Resolver
      def resolve(object : Tuple(String, Graphene::Argument), field_name, argument_values, context, resolution_info)
        name, argument = object

        case field_name
        when "name"
          name
        when "type"
          argument.type
        end
      end
    end
  end
end