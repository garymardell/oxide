# Validation: Executable Definitions
# https://spec.graphql.org/September2025/#sec-Executable-Definitions
#
# GraphQL execution will only consider the executable definitions of a document. This
# means that type system definitions and extensions within a document will not be
# considered during execution.
#
# Formal Specification:
# - For each definition in the document:
#   - definition must be OperationDefinition or FragmentDefinition

module Oxide
  module Validation
    class ExecutableDefinitions < Rule
      def enter(node : Oxide::Language::Nodes::Document, context)
        node.definitions.each do |definition|
          unless executable_definition?(definition)
            definition_name = get_definition_name(definition)
            context.errors << ValidationError.new(
              "The \"#{definition_name}\" definition is not executable."
            )
          end
        end
      end

      private def executable_definition?(definition)
        definition.is_a?(Oxide::Language::Nodes::OperationDefinition) ||
          definition.is_a?(Oxide::Language::Nodes::FragmentDefinition)
      end

      private def get_definition_name(definition)
        case definition
        when Oxide::Language::Nodes::SchemaDefinition
          "schema"
        when Oxide::Language::Nodes::ScalarTypeDefinition
          definition.name
        when Oxide::Language::Nodes::ObjectTypeDefinition
          definition.name
        when Oxide::Language::Nodes::InterfaceTypeDefinition
          definition.name
        when Oxide::Language::Nodes::UnionTypeDefinition
          definition.name
        when Oxide::Language::Nodes::EnumTypeDefinition
          definition.name
        when Oxide::Language::Nodes::InputObjectTypeDefinition
          definition.name
        when Oxide::Language::Nodes::DirectiveDefinition
          definition.name
        else
          definition.class.name.split("::").last
        end
      end
    end
  end
end
