require "../directive"

module Graphene
  module Directives
    class DeprecatedDirective < Graphene::Directive
      def name : String
        "deprecated"
      end

      def arguments : Array(Graphene::Argument)
        [
          Graphene::Argument.new(
            name: "reason",
            type: Graphene::Types::String.new,
            default_value: "No longer supported"
          )
        ]
      end

      def locations : Array(Directive::Location)
        [Directive::Location::FIELD_DEFINITION, Directive::Location::ENUM_VALUE]
      end

      def include?(object, context, argument_values) : Bool
        true
      end
    end
  end
end