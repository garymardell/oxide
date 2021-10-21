module Graphene
  module Introspection
    class InputValueResolver
      include Graphene::Schema::Resolvable

      def resolve(object : Graphene::Schema::Argument, field_name, argument_values)
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