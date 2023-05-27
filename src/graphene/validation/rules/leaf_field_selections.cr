module Graphene
  module Validation
    class LeafFieldSelections < Rule
      def enter(node : Graphene::Language::Nodes::Field, context)
        if field_definition = context.field_definition
          selection_type = field_definition[1].type

          case selection_type
          when Types::ScalarType, Types::EnumType
            selection_set = node.selection_set

            unless selection_set.nil? || selection_set.selections.empty?
              context.errors << Error.new("Cannot select fields on leaf field \"#{node.name}\"")
            end
          when Types::ObjectType, Types::InterfaceType, Types::UnionType
            selection_set = node.selection_set

            if selection_set.nil? || selection_set.selections.empty?
              context.errors << Error.new("Non leaf fields must have a field subselection")
            end
          end
        end
      end
    end
  end
end