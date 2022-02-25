require "../directive"

module Graphene
  module Directives
    class IncludeDirective < Graphene::Directive
      def name : String
        "include"
      end

      def arguments : Array(Graphene::Argument)
        [
          Graphene::Argument.new(
            name: "if",
            type: Graphene::Types::NonNull.new(
              of_type: Graphene::Types::Boolean.new
            )
          )
        ]
      end

      def locations : Array(Directive::Location)
        [Directive::Location::FIELD, Directive::Location::FRAGMENT_SPREAD, Directive::Location::INLINE_FRAGMENT]
      end

      def include?(object, context, argument_values) : Bool
        !!argument_values["if"]
      end
    end
  end
end