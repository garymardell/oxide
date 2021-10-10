module Graphql
  module DSL
    class Enum
      macro value(name, value)
        @[EnumValue(name: "{{name.id}}")]
        def self.{{name.id.downcase}}_value
          Graphql::Type::EnumValue.new(name: "{{name.id}}", value: "{{value.id}}")
        end
      end

      macro graphql_name(name)
        def self.graphql_name
          {{name}}
        end
      end

      def self.graphql_name
        self.name
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile(context)
              values = [] of Graphql::Type::EnumValue

              {% methods = @type.class.methods.select { |m| m.annotation(EnumValue) } %}
              {% for method in methods %}
                values << {{ method.annotation(EnumValue)["name"].downcase.id }}_value
              {% end %}

              Graphql::Type::Enum.new(
                typename: graphql_name,
                values: values
              )
            end
          {% end %}
        end
      end
    end
  end
end