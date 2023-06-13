require "../directive"

module Oxide
  module Directives
    class SkipDirective < Oxide::Directive
      def name : String
        "skip"
      end

      def arguments : Hash(String, Oxide::Argument)
        {
          "if" => Oxide::Argument.new(
            type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::BooleanType.new
            )
          )
        }
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