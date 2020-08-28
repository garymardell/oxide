require "./validator"

module Graphql
  module Validation
    class ValuesValidator < Validator
      def self.validate(schema, query)
        validate_correct_type(schema, query)
        validate_input_object_field_names(schema, query)
        validate_input_object_field_uniqueness(schema, query)
        validate_input_object_required_fields(schema, query)

        [] of Error
      end

      def self.validate_correct_type(schema, query)
      end

      def self.validate_input_object_field_names(schema, query)
      end

      def self.validate_input_object_field_uniqueness(schema, query)
      end

      def self.validate_input_object_required_fields(schema, query)
      end
    end
  end
end