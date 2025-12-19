module Oxide
  module Validation
    class LeafFieldSelections < Rule
      def enter(node : Oxide::Language::Nodes::Field, context)
        if field_definition = context.field_definition
          selection_type = field_definition[1].type

          case selection_type
          when Types::ScalarType, Types::EnumType
            selection_set = node.selection_set

            unless selection_set.nil? || selection_set.selections.empty?
              selection_names = selection_set.selections.select(Oxide::Language::Nodes::Field).map(&.name)
              context.errors << ValidationError.new("Field \"#{node.name}\" must not have a selection since type \"#{selection_type.name}\" has no subfields.")
            end
          when Types::ObjectType, Types::InterfaceType, Types::UnionType
            selection_set = node.selection_set

            if selection_set.nil? || selection_set.selections.empty?
              context.errors << ValidationError.new("Field \"#{node.name}\" of type \"#{selection_type.name}\" must have a selection of subfields. Did you mean \"#{node.name} { ... }\"?")
            end
          end
        end
      end
    end
  end
end