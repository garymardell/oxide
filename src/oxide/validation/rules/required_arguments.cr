# Validation: Required Arguments
# https://spec.graphql.org/September2025/#sec-Required-Arguments
#
# Arguments can be required. An argument is required if the argument type is non-null
# and does not have a default value. Otherwise, the argument is optional.
#
# Formal Specification:
# - For each Field or Directive in the document:
#   - Let arguments be the arguments provided by the Field or Directive.
#   - Let argumentDefinitions be the set of argument definitions of that Field or Directive.
#   - For each argumentDefinition in argumentDefinitions:
#     - Let type be the expected type of argumentDefinition.
#     - Let defaultValue be the default value of argumentDefinition.
#     - If type is Non-Null and defaultValue does not exist:
#       - Let argumentName be the name of argumentDefinition.
#       - Let argument be the argument in arguments named argumentName.
#       - argument must exist.
#       - Let value be the value of argument.
#       - value must not be the null literal.

module Oxide
  module Validation
    class RequiredArguments < Rule
      def enter(node : Oxide::Language::Nodes::Field, context)
        validate_required_arguments(node, context)
      end

      def enter(node : Oxide::Language::Nodes::Directive, context)
        validate_required_arguments(node, context)
      end

      private def validate_required_arguments(node, context)
        provided_arguments = node.arguments.map(&.name).to_set

        argument_definitions = case node
        when Oxide::Language::Nodes::Field
          field_tuple = context.field_definition
          return unless field_tuple

          _field_name, field = field_tuple
          field.arguments
        when Oxide::Language::Nodes::Directive
          directive = context.directive
          return unless directive

          directive.arguments
        else
          return
        end

        argument_definitions.each do |arg_name, arg_def|
          # Check if argument is required (non-null type and no default value)
          if arg_def.type.is_a?(Oxide::Types::NonNullType) && arg_def.default_value.nil?
            unless provided_arguments.includes?(arg_name)
              location = node.to_location
              
              case node
              when Oxide::Language::Nodes::Field
                context.errors << ValidationError.new(
                  "Field '#{node.name}' argument '#{arg_name}' of type '#{arg_def.type}' is required, but it was not provided.",
                  [location]
                )
              when Oxide::Language::Nodes::Directive
                context.errors << ValidationError.new(
                  "Directive '@#{node.name}' argument '#{arg_name}' of type '#{arg_def.type}' is required, but it was not provided.",
                  [location]
                )
              end
            else
              # Check if the provided argument value is not null
              provided_arg = node.arguments.find { |a| a.name == arg_name }
              if provided_arg && provided_arg.value.is_a?(Oxide::Language::Nodes::NullValue)
                location = provided_arg.to_location
                
                case node
                when Oxide::Language::Nodes::Field
                  context.errors << ValidationError.new(
                    "Field '#{node.name}' argument '#{arg_name}' of type '#{arg_def.type}' cannot be null.",
                    [location]
                  )
                when Oxide::Language::Nodes::Directive
                  context.errors << ValidationError.new(
                    "Directive '@#{node.name}' argument '#{arg_name}' of type '#{arg_def.type}' cannot be null.",
                    [location]
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end