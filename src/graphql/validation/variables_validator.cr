require "./validator"

module Graphql
  module Validation
    class VariablesValidator < Validator
      def self.validate(schema, query)
        validate_uniqueness(schema, query)
        validate_are_input_types(schema, query)
        validate_uses_defined(schema, query)
        validate_used(schema, query)
        validate_usages_are_allowed(schema, query)

        [] of Error
      end

      def self.validate_uniqueness(schema, query)
      end

      def self.validate_are_input_types(schema, query)
      end

      def self.validate_uses_defined(schema, query)
      end

      def self.validate_used(schema, query)
      end

      def self.validate_usages_are_allowed(schema, query)
      end
    end
  end
end