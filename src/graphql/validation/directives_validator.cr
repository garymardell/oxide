require "./validator"

module Graphql
  module Validation
    class DirectivesValidator < Validator
      def self.validate(schema, query)
        validate_defined(schema, query)
        validate_in_valid_locations(schema, query)
        validate_unique_per_location(schema, query)

        [] of Error
      end

      def self.validate_defined(schema, query)
      end

      def self.validate_in_valid_locations(schema, query)
      end

      def self.validate_unique_per_location(schema, query)
      end
    end
  end
end