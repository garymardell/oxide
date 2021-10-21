# For each definition definition in the document.
# definition must be OperationDefinition or FragmentDefinition (it must not be TypeSystemDefinition).
module Graphene
  module Validation
    class NoDefinitionIsPresent < Rule
      def validate(definition : Graphene::Language::Nodes::Definition)
        errors = [] of Error

        unless definition.is_a?(Graphene::Language::Nodes::OperationDefinition) || definition.is_a?(Graphene::Language::Nodes::FragmentDefinition)
          errors << Error.new("Definition was not operation or fragment")
        end

        errors
      end
    end
  end
end