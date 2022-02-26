# For each selection in the document
# Let selectionType be the result type of selection
# If selectionType is a scalar or enum:
#   The subselection set of that selection must be empty
# If selectionType is an interface, union, or object
#   The subselection set of that selection must NOT BE empty
module Graphene
  module Validation
    class LeafFieldSelections < Rule
      def enter(node : Graphene::Language::Nodes::Field, context)
        selection_type = context.field_definition.try &.type

        case selection_type
        when Graphene::Types::ScalarType, Graphene::Types::EnumType
          if node.selection_set && node.selection_set.not_nil!.selections.any?
            errors << Error.new("selections on scalar values are not allowed")
          end
        when Graphene::Types::InterfaceType, Graphene::Types::UnionType, Graphene::Types::ObjectType
          if node.selection_set.nil? || node.selection_set.not_nil!.selections.empty?
            errors << Error.new("selection must be provided for #{node.name}")
          end
        end
      end
    end
  end
end