require "./validator"

module Graphql
  module Validation
    class OperationsValidator < Validator
      def self.validate(schema, query)
        validate_name_uniqueness(schema, query)
        validate_anonymous_operations(schema, query)

        [] of Error
      end

      def self.validate_name_uniqueness(schema, query)
      end

      def self.validate_anonymous_operations(schema, query)
      end
    end
  end
end