# - For every operation in the document
#   - For every variable defined on operation
#     - Let variableName be the name of variable
#     - Let variables be the set of all variables named variableName on operation
#     - variables must be a set of one
module Graphql
  module Validation
    class VariableUniqueness < Rule
      property variable_names : Set(String)

      def initialize(schema)
        super(schema)

        @variable_names = Set(String).new
      end

      def exit(node : Graphql::Language::Nodes::OperationDefinition)
        variable_names.clear
      end

      def enter(node : Graphql::Language::Nodes::VariableDefinition)
        return unless node.variable

        variable_name = node.variable.not_nil!.name

        if variable_names.includes?(variable_name)
          errors << Error.new("multiple variables defined with the name #{variable_name}")
        else
          variable_names << variable_name
        end
      end
    end
  end
end