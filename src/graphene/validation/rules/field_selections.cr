module Graphene
  module Validation
    class FieldSelections < Rule
      def enter(node : Graphene::Language::Nodes::Field, context)
        field_name = node.name

        case type = context.parent_type
        when Types::ObjectType, Types::InterfaceType
          unless type.fields.has_key?(field_name)
            context.errors << Error.new("Field \"#{field_name}\" does not exist on \"#{type.name}\"")
          end
        when Types::UnionType
          unless field_name == "__typename"
            context.errors << Error.new("Field \"#{field_name}\" can not be selected on union type \"#{type.name}\"")
          end
        end
      end
    end
  end
end