require "./validator"

module Graphql
  module Validation
    class FragmentsValidator < Validator
      def self.validate(schema, query)
        validate_name_uniqueness(schema, query)
        validate_spread_type_existence(schema, query)
        validate_on_composite_types(schema, query)
        validate_fragment_is_used(schema, query)

        validate_fragment_spread_target_defined(schema, query)
        validate_fragment_spread_is_not_cycle(schema, query)
        validate_fragment_spread_is_possible(schema, query)

        [] of Error
      end

      def self.validate_name_uniqueness(schema, query)
      end

      def self.validate_spread_type_existence(schema, query)
      end

      def self.validate_on_composite_types(schema, query)
      end

      def self.validate_fragment_is_used(schema, query)
      end

      def self.validate_fragment_spread_target_defined(schema, query)
      end

      def self.validate_fragment_spread_is_not_cycle(schema, query)
      end

      def self.validate_fragment_spread_is_possible(schema, query)
      end
    end
  end
end