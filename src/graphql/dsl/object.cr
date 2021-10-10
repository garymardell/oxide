require "./fields"

module Graphql
  module DSL
    abstract class Object
      include Graphql::Schema::Resolvable
      include Graphql::DSL::Fields

      macro graphql_name(name)
        def self.graphql_name
          {{name}}
        end
      end

      def self.graphql_name
        self.name
      end

      macro implements(*interfaces)
        def self.interfaces
          interfaces = [] of Graphql::DSL::Interface.class

          {% for interface in interfaces %}
            interfaces << {{interface}}
          {% end %}

          interfaces
        end


        def self.implements(context)
          interfaces = [] of Graphql::Type::Interface

          {% for interface in interfaces %}
            interfaces << {{interface}}.compile(context)
          {% end %}

          interfaces
        end
      end

      def self.interfaces
        [] of Graphql::DSL::Interface.class
      end

      def self.implements(context)
        [] of Graphql::Type::Interface
      end

      def self.resolve(object, context, field_name, argument_values)
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

            def self.compile(context) : Graphql::Type::Object
              Graphql::Type::Object.new(
                typename: self.graphql_name,
                resolver: Graphql::DSL::ObjectResolver.new(self),
                implements: self.implements(context),
                fields: self.compile_fields(context)
              )
            end

            def self.resolve(object, context, field_name, argument_values)
              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              klass = new

              case field_name
              {% for method in methods %}
              when {{ method.annotation(Field)["name"] }}
                {{method.name}}(object, field_name, argument_values)
              {% end %}
              else
                interfaces.each do |interface|
                  if interface.resolves_field?(field_name)
                    return interface.resolve(object, context, field_name, argument_values)
                  end
                end
              end
            end
          {% end %}
        end
      end
    end
  end
end