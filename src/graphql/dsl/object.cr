require "../schema/resolvable"

module Graphql
  annotation Field; end
  annotation Argument; end

  module DSL
    class Object
      include Graphql::Schema::Resolvable

      def resolve(object, field_name, argument_values)
        nil
      end

      macro field(name, type, null, &block)
        @[Graphql::Field(name: {{name}}, type: {{type}}, null: {{null}})]

        {{block && block.body}}

        def {{name.id}}__field; end
      end

      macro argument(name, type, required)
        @[Graphql::Argument(name: {{name}}, type: {{type}}, required: {{required}})]

        def {{name.id}}__argument; end
      end

      def typename
        name = self.class.name
        name = name.split("::").last
        name.rchop("Type")
      end

      def to_definition
        fields = [] of Graphql::Schema::Field

        {% for field in @type.methods.select { |ivar| ivar.annotation(Graphql::Field) } %}
          {% ann = field.annotation(Graphql::Field) %}

          fields << Graphql::Schema::Field.new(
            name: {{ann[:name]}},
            type: {{ann[:type]}}.try &.to_definition
          )
        {% end %}

        Graphql::Type::Object.new(
          typename: typename,
          resolver: self,
          fields: fields
        )
      end

      def self.to_definition
        new.to_definition
      end
    end

    class Field
      def initialize(@name : String)
      end
    end

    class Id
      def to_definition
        Graphql::Type::Id.new
      end

      def self.to_definition
        new.to_definition
      end
    end

    class List
      property of_type : NonNull | Id | Object.class | List

      def initialize(@of_type)
      end

      def to_definition
        Graphql::Type::List.new(
          of_type: of_type.to_definition
        )
      end
    end

    class NonNull
      property of_type : NonNull | Id | Object.class | List

      def initialize(@of_type)
      end

      def to_definition
        Graphql::Type::NonNull.new(
          of_type: of_type.to_definition
        )
      end

      def self.to_definition
        new.to_definition
      end
    end
  end
end