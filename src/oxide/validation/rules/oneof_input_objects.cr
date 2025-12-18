# Validation: OneOf Input Objects
# https://spec.graphql.org/September2025/#sec-OneOf-Input-Objects
#
# Input objects with the @oneOf directive must have exactly one field provided.
#
# Formal Specification:
# - For each input object value in the document where the input object type has @oneOf:
#   - Exactly one field must be provided
#   - That field must not be null

module Oxide
  module Validation
    class OneOfInputObjects < Rule
      def enter(node : Oxide::Language::Nodes::ObjectValue, context)
        input_type = context.input_type
        return unless input_type
        
        # Unwrap non-null
        unwrapped = input_type
        while unwrapped.is_a?(Oxide::Types::NonNullType)
          unwrapped = unwrapped.of_type
        end
        
        return unless unwrapped.is_a?(Oxide::Types::InputObjectType)
        
        # Check if this input object has @oneOf directive
        return unless has_oneof_directive?(unwrapped)
        
        # Count non-null fields provided
        non_null_fields = node.fields.reject do |field|
          field.value.is_a?(Oxide::Language::Nodes::NullValue)
        end
        
        if non_null_fields.size != 1
          location = node.to_location
          context.errors << ValidationError.new(
            "OneOf Input Object '#{unwrapped.name}' must have exactly one field provided, got #{non_null_fields.size}.",
            [location]
          )
        end
      end
      
      private def has_oneof_directive?(input_type : Oxide::Types::InputObjectType)
        input_type.applied_directives.any? { |d| d.name == "oneOf" }
      end
    end
  end
end
