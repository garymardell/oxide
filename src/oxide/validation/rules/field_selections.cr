module Oxide
  module Validation
    class FieldSelections < Rule
      def enter(node : Oxide::Language::Nodes::Field, context)
        field_name = node.name

        case type = context.parent_type
        when Types::ObjectType, Types::InterfaceType
          unless type.fields.has_key?(field_name) || introspection_field?(type, field_name)
            context.errors << ValidationError.new("Field '#{field_name}' doesn't exist on type '#{type.name}'")
          end
        when Types::UnionType
          unless field_name == "__typename"
            context.errors << ValidationError.new("Selections can't be made directly on unions (see selections on #{type.name})")
          end
        end
      end

      private def introspection_field?(type, field_name)
        (type.name == "Query" && field_name == "__schema") || field_name == "__typename"
      end
    end
  end
end