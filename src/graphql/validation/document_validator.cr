require "./validator"

# For each definition definition in the document.
# definition must be OperationDefinition or FragmentDefinition (it must not be TypeSystemDefinition).
module Graphql
  module Validation
    class DocumentValidator < Validator
      def self.validate(schema, query)
        validate_definitions(schema, query)

        [] of Error
      end

      def self.validate_definitions(schema, query)
        query.document.definitions.each do |definition|
          unless definition.is_a?(Graphql::Language::Nodes::OperationDefinition) || definition.is_a?(Graphql::Language::Nodes::FragmentDefinition)
            # errors << Error.new
          end
        end
      end
    end
  end
end