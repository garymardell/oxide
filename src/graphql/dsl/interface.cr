require "./fields"

module Graphql
  module DSL
    class Interface
      include Graphql::DSL::Fields

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

      def self.resolves_field?(field_name)
        false
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile_fields(context) : Array(Graphql::Schema::Field)
              fields = [] of Graphql::Schema::Field

              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              {% for method in methods %}
                arguments = [] of Graphql::Schema::Argument

                {% for argument in method.annotations(Argument) %}
                  arguments << Graphql::Schema::Argument.new(
                    name: {{argument["name"]}},
                    type: {{argument["type"]}}.compile(context)
                  )
                {% end %}

                fields << Graphql::Schema::Field.new(
                  name: {{ method.annotation(Field)["name"] }},
                  type: {{method.annotation(Field)["name"].id}}_type(context),
                  arguments: arguments
                )
              {% end %}

              fields
            end

            def self.compile(context)
              Graphql::Type::Interface.new(
                name: self.graphql_name,
                type_resolver: Graphql::DSL::InterfaceResolver.new(self),
                fields: self.compile_fields(context)
              )
            end

            def self.resolves_field?(field_name)
              field_names = [] of String

              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}
              {% for method in methods %}
                field_names << {{ method.annotation(Field)["name"] }}
              {% end %}

              field_names.includes?(field_name)
            end

            def self.resolve(object, context, field_name, argument_values)
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