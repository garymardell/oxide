# For each definition definition in the document.
# definition must be OperationDefinition or FragmentDefinition (it must not be TypeSystemDefinition).
module Graphql
  module Validation
    class NoDefinitionIsPresent < Rule
      def validate(definition : Graphql::Language::Nodes::Definition)
        errors = [] of Error

        unless definition.is_a?(Graphql::Language::Nodes::OperationDefinition) || definition.is_a?(Graphql::Language::Nodes::FragmentDefinition)
          errors << Error.new("Definition was not operation or fragment")
        end

        errors
      end
    end
  end
end