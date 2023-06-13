require "../directive"

module Oxide
  module Directives
    class DeprecatedDirective < Oxide::Directive
      def name : String
        "deprecated"
      end

      def arguments : Hash(String, Oxide::Argument)
        {
          "reason" => Oxide::Argument.new(
            type: Oxide::Types::StringType.new,
            default_value: "No longer supported"
          )
        }
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