module Graphene
  module Validation
    class Context
      alias Composite = Graphene::Type::Object | Graphene::Type::Interface | Graphene::Type::Union

      getter schema : Graphene::Schema
      getter query : Graphene::Query

      property argument : Graphene::Schema::Argument?

      getter type_stack : Array(Graphene::Type?)
      getter parent_type_stack : Array(Composite?)
      getter input_type_stack : Array(Graphene::Type?)
      getter field_definition_stack : Array(Graphene::Schema::Field?)

      def initialize(@schema, @query)
        @type_stack = [] of Graphene::Type?
        @input_type_stack = [] of Graphene::Type?
        @parent_type_stack = [] of Composite?
        @field_definition_stack = [] of Graphene::Schema::Field?
      end

      def type
        type_stack.last?
      end

      def input_type
        input_type_stack.last?
      end

      def parent_type
        parent_type_stack.last?
      end

      def field_definition
        field_definition_stack.last?
      end
    end
  end
end