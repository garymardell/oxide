require "./fields"

module Graphql
  module DSL
    class Union
      macro graphql_name(name)
        def self.graphql_name
          {{name}}
        end
      end

      def self.graphql_name
        self.name
      end

      def self.resolve_type(object, context)
      end

      def self.resolve(object, context, field_name, argument_values)
      end

      macro possible_types(*types)
        def self.possible_types(context)
          possible_types = [] of Graphql::Type

          {% for type in types %}
            possible_types << {{type}}.compile(context)
          {% end %}

          possible_types
        end
      end

      def self.possible_types(context)
        [] of Graphql::Type
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile(context)
              Graphql::Type::Union.new(
                typename: self.graphql_name,
                type_resolver: Graphql::DSL::UnionResolver.new(self),
                possible_types: self.possible_types(context)
              )
            end
          {% end %}
        end
      end
    end
  end
end