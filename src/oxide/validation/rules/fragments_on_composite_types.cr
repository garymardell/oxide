# Validation: Fragments on Composite Types
# https://spec.graphql.org/September2025/#sec-Fragments-on-Composite-Types
#
# Fragments can only be declared on unions, interfaces, and objects. They are invalid
# on scalars. They can only be applied on non-leaf fields. This rule applies to both
# inline and named fragments.
#
# Formal Specification:
# - For each fragment defined in the document:
#   - The target type of fragment must have kind UNION, INTERFACE, or OBJECT.

module Oxide
  module Validation
    class FragmentsOnCompositeTypes < Rule
      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        return unless type_condition = node.type_condition

        type_name = type_condition.name
        type = context.schema.get_type(type_name)
        
        return unless type
        
        unless composite_type?(type)
          type_kind = get_type_kind(type)
          context.errors << ValidationError.new(
            "Fragment \"#{node.name}\" cannot condition on non composite type \"#{type_name}\"."
          )
        end
      end

      def enter(node : Oxide::Language::Nodes::InlineFragment, context)
        return unless type_condition = node.type_condition

        type_name = type_condition.name
        type = context.schema.get_type(type_name)
        
        return unless type
        
        unless composite_type?(type)
          type_kind = get_type_kind(type)
          context.errors << ValidationError.new(
            "Fragment cannot condition on non composite type \"#{type_name}\"."
          )
        end
      end

      private def composite_type?(type)
        case type
        when Oxide::Types::ObjectType, Oxide::Types::InterfaceType, Oxide::Types::UnionType
          true
        when Oxide::Types::NonNullType
          composite_type?(type.of_type)
        when Oxide::Types::ListType
          composite_type?(type.of_type)
        else
          false
        end
      end

      private def get_type_kind(type)
        case type
        when Oxide::Types::ScalarType
          "Scalar"
        when Oxide::Types::EnumType
          "Enum"
        when Oxide::Types::InputObjectType
          "InputObject"
        when Oxide::Types::ObjectType
          "Object"
        when Oxide::Types::InterfaceType
          "Interface"
        when Oxide::Types::UnionType
          "Union"
        when Oxide::Types::ListType
          "List"
        when Oxide::Types::NonNullType
          "NonNull"
        else
          "Unknown"
        end
      end
    end
  end
end