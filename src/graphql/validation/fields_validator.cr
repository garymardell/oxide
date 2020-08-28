require "./validator"

module Graphql
  module Validation
    class FieldsValidator < Validator
      def self.validate(schema, query)
        errors = [] of Error
        errors.concat validate_field_selections(schema, query)
        errors.concat validate_field_selection_merging(schema, query)
        errors.concat validate_leaf_field_selections(schema, query)
        errors
      end

      # Formal Specification
      #
      # - For each selection in the document.
      # - Let fieldName be the target field of selection
      # - fieldName must be defined on type in scope
      def self.validate_field_selections(schema, query)
        errors = [] of Error

        errors
      end

      def self.validate_field_selection_merging(schema, query)
        errors = [] of Error

        errors
      end

      def self.validate_leaf_field_selections(schema, query)
        errors = [] of Error

        errors
      end
    end
  end
end