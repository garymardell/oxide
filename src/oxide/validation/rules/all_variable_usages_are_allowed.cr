# Validation: All Variable Usages Are Allowed
# https://spec.graphql.org/September2025/#sec-All-Variable-Usages-are-Allowed
#
# Variable usages must be compatible with the arguments they are passed to.
#
# Formal Specification:
# - For each operation in the document:
#   - For each variableUsage in that operation:
#     - Let variableType be the type of variableUsage
#     - Let locationType be the type expected for the location variableUsage is used
#     - Let hasDefault be true if variableUsage has a default value
#     - IsVariableUsageAllowed(variableType, locationType, hasDefault) must be true

module Oxide
  module Validation
    class AllVariableUsagesAreAllowed < Rule
      @current_operation : Oxide::Language::Nodes::OperationDefinition?
      
      def initialize
        @variable_definitions = {} of String => {Oxide::Type?, Bool} # type, has_default
        @variable_usages = [] of {String, Oxide::Type?, Oxide::Language::Nodes::Variable}
        @current_operation = nil
      end

      def enter(node : Oxide::Language::Nodes::OperationDefinition, context)
        @current_operation = node
        @variable_definitions.clear
        @variable_usages.clear
        
        # Collect variable definitions for this operation
        node.variable_definitions.each do |var_def|
          var_name = var_def.variable.name
          var_type = context.schema.get_type_from_ast(var_def.type)
          has_default = !var_def.default_value.nil?
          @variable_definitions[var_name] = {var_type, has_default}
        end
      end

      def enter(node : Oxide::Language::Nodes::Variable, context)
        # Track variable usage with its expected location type
        location_type = context.input_type
        @variable_usages << {node.name, location_type, node}
      end

      def leave(node : Oxide::Language::Nodes::OperationDefinition, context)
        # Check all variable usages in this operation
        @variable_usages.each do |var_name, location_type, var_node|
          var_def = @variable_definitions[var_name]?
          next unless var_def # Another rule handles undefined variables
          
          var_type, has_default = var_def
          next unless var_type && location_type
          
          unless is_variable_usage_allowed?(var_type, location_type, has_default, context)
            location = var_node.to_location
            context.errors << ValidationError.new(
              "Variable '#{var_name}' of type '#{type_to_string(var_type)}' used in position expecting type '#{type_to_string(location_type)}'.",
              [location]
            )
          end
        end
        
        @current_operation = nil
      end

      # IsVariableUsageAllowed(variableType, locationType, hasDefault)
      private def is_variable_usage_allowed?(variable_type, location_type, has_default, context)
        # If locationType is a non-null type AND variableType is NOT a non-null type:
        if location_type.is_a?(Oxide::Types::NonNullType) && !variable_type.is_a?(Oxide::Types::NonNullType)
          # Let hasNonNullVariableDefaultValue be true if a default value exists for the variable
          # and it's not null
          has_non_null_default = has_default
          
          # If hasNonNullVariableDefaultValue is false, return false
          return false unless has_non_null_default
          
          # Let nullableLocationType be the unwrapped nullable type of locationType
          nullable_location_type = location_type.of_type
          
          # Return AreTypesCompatible(variableType, nullableLocationType)
          return are_types_compatible?(variable_type, nullable_location_type, context)
        end
        
        # Return AreTypesCompatible(variableType, locationType)
        are_types_compatible?(variable_type, location_type, context)
      end

      # AreTypesCompatible(variableType, locationType)
      private def are_types_compatible?(variable_type, location_type, context)
        # If locationType is a non-null type:
        if location_type.is_a?(Oxide::Types::NonNullType)
          # If variableType is NOT a non-null type, return false
          return false unless variable_type.is_a?(Oxide::Types::NonNullType)
          
          # Let nullableVariableType be the unwrapped nullable type of variableType
          # Let nullableLocationType be the unwrapped nullable type of locationType
          nullable_variable_type = variable_type.of_type
          nullable_location_type = location_type.of_type
          
          # Return AreTypesCompatible(nullableVariableType, nullableLocationType)
          return are_types_compatible?(nullable_variable_type, nullable_location_type, context)
        end
        
        # If variableType is a non-null type:
        if variable_type.is_a?(Oxide::Types::NonNullType)
          # Let nullableVariableType be the unwrapped nullable type of variableType
          nullable_variable_type = variable_type.of_type
          
          # Return AreTypesCompatible(nullableVariableType, locationType)
          return are_types_compatible?(nullable_variable_type, location_type, context)
        end
        
        # If locationType is a list type:
        if location_type.is_a?(Oxide::Types::ListType)
          # If variableType is NOT a list type, return false
          return false unless variable_type.is_a?(Oxide::Types::ListType)
          
          # Let itemVariableType be the unwrapped item type of variableType
          # Let itemLocationType be the unwrapped item type of locationType
          item_variable_type = variable_type.of_type
          item_location_type = location_type.of_type
          
          # Return AreTypesCompatible(itemVariableType, itemLocationType)
          return are_types_compatible?(item_variable_type, item_location_type, context)
        end
        
        # If variableType is a list type, return false
        return false if variable_type.is_a?(Oxide::Types::ListType)
        
        # Return true if variableType and locationType are identical
        same_type?(variable_type, location_type)
      end

      private def same_type?(type1, type2)
        case type1
        when Oxide::Types::ScalarType
          type2.is_a?(Oxide::Types::ScalarType) && type1.class == type2.class
        when Oxide::Types::EnumType
          type2.is_a?(Oxide::Types::EnumType) && type1.name == type2.name
        when Oxide::Types::InputObjectType
          type2.is_a?(Oxide::Types::InputObjectType) && type1.name == type2.name
        when Oxide::Types::ObjectType
          type2.is_a?(Oxide::Types::ObjectType) && type1.name == type2.name
        when Oxide::Types::InterfaceType
          type2.is_a?(Oxide::Types::InterfaceType) && type1.name == type2.name
        when Oxide::Types::UnionType
          type2.is_a?(Oxide::Types::UnionType) && type1.name == type2.name
        else
          false
        end
      end

      private def type_to_string(type)
        case type
        when Oxide::Types::NonNullType
          "#{type_to_string(type.of_type)}!"
        when Oxide::Types::ListType
          "[#{type_to_string(type.of_type)}]"
        when Oxide::Types::ScalarType, Oxide::Types::EnumType, Oxide::Types::InputObjectType, 
             Oxide::Types::ObjectType, Oxide::Types::InterfaceType, Oxide::Types::UnionType
          type.name
        else
          "Unknown"
        end
      end
    end
  end
end
