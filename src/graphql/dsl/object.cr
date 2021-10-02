module Graphql
  module DSL
    abstract class Object
      include Graphql::Schema::Resolvable

      macro field(name, type, null)
        @[Field(name: "{{name.id}}")]
        def self.{{name.id}}_resolve(object, field_name, argument_values)
          klass = new
          klass.{{name.id}}(object, argument_values)
        end

        def {{name.id}}(object, argument_values)
          if object.responds_to?(:{{name.id}})
            object.{{name.id}}
          end
        end

        def self.{{name.id}}_type
          {% if type.is_a?(ArrayLiteral) %}
            field_type = Graphql::Type::List.new(of_type: {{type}}.first.compile())
          {% else %}
            field_type = {{type}}.compile
          {% end %}

          unless {{null}}
            Graphql::Type::NonNull.new(of_type: field_type)
          else
            field_type
          end
        end

        def self.graphql_name
          name
        end
      end

      def self.resolve(object, field_name, argument_values)
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile : Graphql::Type::Object
              fields = [] of Graphql::Schema::Field

              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              {% for method in methods %}
                fields << Graphql::Schema::Field.new(
                  name: {{ method.annotation(Field)["name"] }},
                  type: {{method.annotation(Field)["name"].id}}_type()
                )
              {% end %}

              Graphql::Type::Object.new(
                typename: self.graphql_name,
                resolver: Graphql::DSL::ObjectResolver.new(self),
                fields: fields
              )
            end

            def self.resolve(object, field_name, argument_values)
              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              klass = new

              case field_name
              {% for method in methods %}
              when {{ method.annotation(Field)["name"] }}
                {{method.name}}(object, field_name, argument_values)
              {% end %}
              end
            end
          {% end %}
        end
      end
    end
  end
end