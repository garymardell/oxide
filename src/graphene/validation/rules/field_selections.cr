module Graphene
  module Validation
    class FieldSelections < Rule
      def enter(node : Graphene::Language::Nodes::Field, context)
        field_name = node.name

        return unless type = context.parent_type

        case type
        when Graphene::Types::ObjectType, Graphene::Types::InterfaceType
          if context.field_definition.nil?
            errors << Error.new("field #{field_name} not defined on #{type.name}")
          end
        end
      end
    end
  end
end