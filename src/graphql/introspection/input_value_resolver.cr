module Graphql
  module Introspection
    class InputValueResolver
      include Graphql::Schema::Resolvable

      def resolve(object : Graphql::Schema::Argument, field_name, argument_values)
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