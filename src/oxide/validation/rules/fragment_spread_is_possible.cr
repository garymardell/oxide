# Validation: Fragment Spread Is Possible
# https://spec.graphql.org/September2025/#sec-Fragment-spread-is-possible
#
# Fragments are declared on a type and will only apply when the runtime object type
# matches the type condition. They also are spread within the context of a parent type.
# A fragment spread is only valid if its type condition could ever apply within the
# parent type.
#
# Formal Specification:
# - For each spread (named or inline) in the document:
#   - Let fragment be the target of the spread
#   - Let fragmentType be the type condition of fragment
#   - Let parentType be the type of the selection set containing the spread
#   - Let applicableTypes be the intersection of GetPossibleTypes(fragmentType)
#     and GetPossibleTypes(parentType)
#   - applicableTypes must not be empty

module Oxide
  module Validation
    class FragmentSpreadIsPossible < Rule
      alias TypeUnion = Oxide::Types::ObjectType | Oxide::Types::InterfaceType | Oxide::Types::UnionType | Oxide::Types::ScalarType | Oxide::Types::EnumType | Oxide::Types::InputObjectType | Oxide::Types::ListType | Oxide::Types::NonNullType
      
      def initialize
        @fragment_types = {} of String => TypeUnion
      end

      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        if type_condition = node.type_condition
          type = context.schema.get_type(type_condition.name)
          @fragment_types[node.name] = type if type
        end
      end

      def enter(node : Oxide::Language::Nodes::FragmentSpread, context)
        fragment_type = @fragment_types[node.name]?
        parent_type = context.parent_type
        
        return unless fragment_type && parent_type
        
        unless spread_is_possible?(fragment_type, parent_type, context)
          context.errors << ValidationError.new(
            "Fragment \"#{node.name}\" cannot be spread here as objects of type \"#{type_name(parent_type)}\" can never be of type \"#{type_name(fragment_type)}\"."
          )
        end
      end

      def enter(node : Oxide::Language::Nodes::InlineFragment, context)
        return unless type_condition = node.type_condition
        
        fragment_type = context.schema.get_type(type_condition.name)
        parent_type = context.parent_type
        
        return unless fragment_type && parent_type
        
        unless spread_is_possible?(fragment_type, parent_type, context)
          context.errors << ValidationError.new(
            "Fragment cannot be spread here as objects of type \"#{type_name(parent_type)}\" can never be of type \"#{type_name(fragment_type)}\"."
          )
        end
      end

      private def spread_is_possible?(fragment_type : TypeUnion, parent_type : TypeUnion, context) : Bool
        fragment_possible_types = get_possible_types(fragment_type, context)
        parent_possible_types = get_possible_types(parent_type, context)
        
        # Check if there's any intersection
        fragment_possible_types.any? { |t| parent_possible_types.includes?(t) }
      end

      private def get_possible_types(type : TypeUnion, context) : Set(Oxide::Types::ObjectType)
        case type
        when Oxide::Types::ObjectType
          Set{type}
        when Oxide::Types::InterfaceType
          # Get all object types that implement this interface
          objects = Set(Oxide::Types::ObjectType).new
          context.schema.types.each do |schema_type|
            if schema_type.is_a?(Oxide::Types::ObjectType)
              if schema_type.interfaces.any? { |iface| iface.name == type.name }
                objects << schema_type
              end
            end
          end
          objects
        when Oxide::Types::UnionType
          # Get all member types (which should be ObjectTypes)
          objects = Set(Oxide::Types::ObjectType).new
          type.possible_types.each do |member_type|
            objects << member_type if member_type.is_a?(Oxide::Types::ObjectType)
          end
          objects
        else
          Set(Oxide::Types::ObjectType).new
        end
      end

      private def type_name(type : TypeUnion) : String
        case type
        when Oxide::Types::ObjectType, Oxide::Types::InterfaceType, Oxide::Types::UnionType, Oxide::Types::ScalarType, Oxide::Types::EnumType, Oxide::Types::InputObjectType
          type.name
        else
          "Unknown"
        end
      end
    end
  end
end
