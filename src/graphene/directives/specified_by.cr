require "../directive"

module Graphene
  module Directives
    class SpecifiedByDirective < Graphene::Directive
      def name : String
        "specifiedBy"
      end

      def arguments : Hash(String, Graphene::Argument)
        {
          "url" => Graphene::Argument.new(
            type: Graphene::Types::NonNullType.new(
              of_type: Graphene::Types::StringType.new
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