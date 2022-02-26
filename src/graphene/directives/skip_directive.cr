require "../directive"

module Graphene
  module Directives
    class SkipDirective < Graphene::Directive
      def name : String
        "skip"
      end

      def arguments : Array(Graphene::Argument)
        [
          Graphene::Argument.new(
            name: "if",
            type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::BooleanType.new
            )
          )
        ]
      end

      def locations : Array(Directive::Location)
        [Directive::Location::FIELD, Directive::Location::FRAGMENT_SPREAD, Directive::Location::INLINE_FRAGMENT]
      end

      def include?(object, context, argument_values) : Bool
        !argument_values["if"]
      end
    end
  end
end