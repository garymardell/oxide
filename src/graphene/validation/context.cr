module Graphene
  module Validation
    class Context
      alias Composite = Graphene::Types::ObjectType | Graphene::Types::InterfaceType | Graphene::Types::UnionType

      getter schema : Graphene::Schema
      getter query : Graphene::Query

      getter type_stack : Array(Graphene::Type?)
      getter parent_type_stack : Array(Composite?)
      getter input_type_stack : Array(Graphene::Type?)
      getter field_definition_stack : Array(Graphene::Field?)
      # default_value_stack
      property directive : Graphene::Directive?
      property argument : Graphene::Argument?
      property enum_value : Graphene::Types::EnumValue?

      getter errors : Array(Error)

      def initialize(@schema, @query)
        @type_stack = [] of Graphene::Type?
        @input_type_stack = [] of Graphene::Type?
        @parent_type_stack = [] of Composite?
        @field_definition_stack = [] of Graphene::Field?
        @errors = [] of Error
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