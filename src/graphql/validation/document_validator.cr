require "./validator"

# For each definition definition in the document.
# definition must be OperationDefinition or FragmentDefinition (it must not be TypeSystemDefinition).
module Graphql
  module Validation
    class DocumentValidator < Validator
      def self.validate(schema, query)
        validate_definitions(schema, query)
      end

      def self.validate_definitions(schema, query)
        errors = [] of Error

        query.document.definitions.each do |definition|
          unless definition.is_a?(Graphql::Language::Nodes::OperationDefinition) || definition.is_a?(Graphql::Language::Nodes::FragmentDefinition)
            errors << Error.new("Definition was not operation or fragment")
          end
        end

        errors
      end
    end
  end
end