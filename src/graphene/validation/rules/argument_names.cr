# For each argument in the document
# Let argumentName be the Name of argument.
# Let argumentDefinition be the argument definition provided by the parent field or definition named argumentName.
# argumentDefinition must exist.
module Graphene
  module Validation
    class ArgumentNames < Rule
      def enter(node : Graphene::Language::Nodes::Argument, context)
        unless context.argument
          errors << Error.new("argument #{node.name} is not valid for #{context.field_definition.try &.name}")
        end
      end
    end
  end
end