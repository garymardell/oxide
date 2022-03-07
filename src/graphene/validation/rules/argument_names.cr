# For each argument in the document
# Let argumentName be the Name of argument.
# Let argumentDefinition be the argument definition provided by the parent field or definition named argumentName.
# argumentDefinition must exist.
module Graphene
  module Validation
    class ArgumentNames < Rule
      def enter(node : Graphene::Language::Nodes::Argument, context)
        definition = context.argument
        field_definition = context.field_definition
        parent_type = context.parent_type

        if !definition && field_definition && parent_type
          field_name, field = field_definition

          type_name = if parent_type.responds_to?(:name)
            parent_type.name
          end

          context.errors << Error.new("Unknown argument \"#{node.name}\" on field \"#{type_name}.#{field_name}\"")
        end
      end
    end
  end
end