module Graphql
  module Introspection
    class SchemaResolver
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
        case field_name
        when "types"
          if query = schema.try &.query
            query.fields.map(&.type)
          end
        end
      end
    end
  end
end