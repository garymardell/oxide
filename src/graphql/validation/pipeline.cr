require "./validator"
require "./**"

module Graphql
  module Validation
    class Pipeline
      property errors : Array(Error)

      private getter validators : Array(Validator.class)
      private getter schema : Graphql::Schema
      private getter query : Graphql::Query

      def self.default_validators
        [
          DocumentValidator
        ]
      end

      def initialize(@schema, @query, @validators = default_validators)
        @errors = [] of Error
      end

      def execute
        validators.each do |validator|
          errors.concat validator.validate(schema, query)
        end

        errors.any?
      end
    end
  end
end