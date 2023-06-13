require "../directive"

module Oxide
  module Directives
    class SpecifiedByDirective < Oxide::Directive
      def name : String
        "specifiedBy"
      end

      def arguments : Hash(String, Oxide::Argument)
        {
          "url" => Oxide::Argument.new(
            type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::StringType.new
            )
          )
        }
      end

      def locations : Array(Directive::Location)
        [Directive::Location::SCALAR]
      end

      def include?(object, context, argument_values) : Bool
        true
      end
    end
  end
end