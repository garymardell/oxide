require "./validator"

module Graphql
  module Validation
    class ArgumentsValidator < Validator
      def self.validate(schema, query)
        validate_argument_names(schema, query)
        validate_argument_uniqueness(schema, query)

        [] of Error
      end

      def self.validate_argument_names(schema, query)
      end

      def self.validate_argument_uniqueness(schema, query)
      end
    end
  end
end