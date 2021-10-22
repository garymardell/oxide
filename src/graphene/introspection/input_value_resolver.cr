module Graphene
  module Introspection
    class InputValueResolver < Graphene::Schema::Resolver
      def resolve(object : Graphene::Schema::Argument, context, field_name, argument_values)
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