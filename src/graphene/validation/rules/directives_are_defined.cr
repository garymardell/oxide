module Graphene
  module Validation
    class DirectivesAreDefined < Rule
      def enter(node : Graphene::Language::Nodes::Directive, context)
        directive_name = node.name
        directive_definition = context.schema.directives.find { |directive| directive.name == directive_name }

        unless directive_definition
          context.errors << Error.new("Directive @#{directive_name} is not defined")
        end
      end
    end
  end
end
