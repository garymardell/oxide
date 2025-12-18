# Validation: Field Selection Merging
# https://spec.graphql.org/September2025/#sec-Field-Selection-Merging
#
# If multiple field selections with the same response names are encountered during execution,
# the fields should be merged together when the parent types are the same or compatible.
#
# Formal Specification:
# - Let set be any selection set defined in the document
# - FieldsInSetCanMerge(set) must be true

module Oxide
  module Validation
    class FieldSelectionMerging < Rule
      def enter(node : Oxide::Language::Nodes::SelectionSet, context)
        # Collect all fields in this selection set (including from fragments)
        fields = collect_fields(node, context)
        
        # Group fields by response name (alias or field name)
        fields_by_name = {} of String => Array({String, Oxide::Language::Nodes::Field, Oxide::Type?})
        
        fields.each do |parent_type, field, field_def_type|
          response_name = field.alias || field.name
          fields_by_name[response_name] ||= [] of {String, Oxide::Language::Nodes::Field, Oxide::Type?}
          fields_by_name[response_name] << {parent_type, field, field_def_type}
        end
        
        # Check if fields with same response name can merge
        fields_by_name.each do |response_name, field_list|
          next if field_list.size < 2
          
          unless fields_can_merge?(field_list, context)
            locations = field_list.map { |_, field, _| field.to_location }
            context.errors << ValidationError.new(
              "Fields '#{response_name}' conflict because they have different field names or incompatible types. " \
              "Use different aliases on the fields to fetch both if this was intentional.",
              locations
            )
          end
        end
      end

      private def collect_fields(selection_set, context)
        fields = [] of {String, Oxide::Language::Nodes::Field, Oxide::Type?}
        parent_type = context.parent_type
        
        return fields unless parent_type
        
        parent_type_name = case parent_type
        when Oxide::Types::ObjectType, Oxide::Types::InterfaceType, Oxide::Types::UnionType
          parent_type.name
        else
          "Unknown"
        end
        
        selection_set.selections.each do |selection|
          case selection
          when Oxide::Language::Nodes::Field
            # Get the field type from the parent
            field_def = get_field_def(parent_type, selection.name, context)
            field_type = field_def.try &.type
            fields << {parent_type_name, selection, field_type}
          when Oxide::Language::Nodes::InlineFragment
            # Inline fragments contribute fields from their selection set
            if selection.selection_set
              fragment_type = if type_cond = selection.type_condition
                context.schema.get_type(type_cond.name)
              else
                parent_type
              end
              
              if fragment_type
                sub_fields = collect_fields_with_type(selection.selection_set, fragment_type, context)
                fields.concat(sub_fields)
              end
            end
          when Oxide::Language::Nodes::FragmentSpread
            # Fragment spreads need to be resolved - skip for now in this simplified version
            # A complete implementation would need to track and expand fragment definitions
          end
        end
        
        fields
      end

      private def collect_fields_with_type(selection_set, parent_type, context)
        fields = [] of {String, Oxide::Language::Nodes::Field, Oxide::Type?}
        
        selection_set.selections.each do |selection|
          case selection
          when Oxide::Language::Nodes::Field
            field_def = get_field_def(parent_type, selection.name, context)
            field_type = field_def.try &.type
            type_name = case parent_type
            when Oxide::Types::ObjectType, Oxide::Types::InterfaceType, Oxide::Types::UnionType
              parent_type.name
            else
              "Unknown"
            end
            fields << {type_name, selection, field_type}
          end
        end
        
        fields
      end

      private def get_field_def(parent_type, field_name, context)
        case parent_type
        when Oxide::Types::ObjectType
          parent_type.fields[field_name]?
        when Oxide::Types::InterfaceType
          parent_type.fields[field_name]?
        else
          nil
        end
      end

      private def fields_can_merge?(field_list, context)
        # Check if all fields have the same field name (not just response name)
        field_names = field_list.map { |_, field, _| field.name }.uniq
        return false if field_names.size > 1
        
        # Check if return types are compatible
        types = field_list.map { |_, _, type| type }.compact
        return true if types.empty?
        
        # All types should have the same shape
        first_type = types.first
        types.all? { |type| same_type_shape?(first_type, type, context) }
      end

      private def same_type_shape?(type1, type2, context)
        # Unwrap non-null
        t1 = unwrap_non_null(type1)
        t2 = unwrap_non_null(type2)
        
        # Both lists or both not lists
        t1_list = t1.is_a?(Oxide::Types::ListType)
        t2_list = t2.is_a?(Oxide::Types::ListType)
        
        return false if t1_list != t2_list
        
        if t1.is_a?(Oxide::Types::ListType) && t2.is_a?(Oxide::Types::ListType)
          return same_type_shape?(t1.of_type, t2.of_type, context)
        end
        
        # For scalars and enums, must be exactly the same type
        case t1
        when Oxide::Types::ScalarType
          t2.is_a?(Oxide::Types::ScalarType) && t1.class == t2.class
        when Oxide::Types::EnumType
          t2.is_a?(Oxide::Types::EnumType) && t1.name == t2.name
        when Oxide::Types::ObjectType
          t2.is_a?(Oxide::Types::ObjectType) && t1.name == t2.name
        when Oxide::Types::InterfaceType, Oxide::Types::UnionType
          # For composite types, they're compatible if they overlap
          true
        else
          true
        end
      end

      private def unwrap_non_null(type)
        type.is_a?(Oxide::Types::NonNullType) ? type.of_type : type
      end
    end
  end
end
