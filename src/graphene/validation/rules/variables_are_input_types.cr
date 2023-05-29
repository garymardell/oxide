
module Graphene
  module Validation
    class VariablesAreInputTypes < Rule
      def enter(node : Graphene::Language::Nodes::VariableDefinition, context)
        if variable = node.variable
          unless context.input_type
            context.errors << Error.new("Variable \"#{variable.name}\" must be an input type")
          end
        end
      end
    end
  end
end