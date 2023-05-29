
module Graphene
  module Validation
    class VariableUniqueness < Rule
      def enter(node : Graphene::Language::Nodes::OperationDefinition, context)
        variable_names = [] of String

        node.variable_definitions.each do |variable_definition|
          if variable = variable_definition.variable
            if variable_names.includes?(variable.name)
              context.errors << Error.new("Multiple variables with the same name \"#{variable.name}\"")
            else
              variable_names << variable.name
            end
          end
        end
      end
    end
  end
end