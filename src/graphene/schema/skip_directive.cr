module Graphene
  class Schema
    class SkipDirective
      def self.skip?(directive, variable_values)
        argument = directive.arguments.find(&.name.=== "if")

        return false if argument.nil?
        return false if argument.not_nil!.value.nil?

        value = argument.not_nil!.value.not_nil!.value

        case value
        when Bool
          !!value
        when Graphene::Language::Nodes::Variable
          variable_values.fetch(value.name, false)
        else
          false
        end
      end
    end
  end
end