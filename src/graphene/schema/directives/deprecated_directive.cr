module Graphene
  class Schema
    module Directives
      class DeprecatedDirective < Graphene::Schema::Directive
        def name : String
          "deprecated"
        end

        def arguments : Array(Graphene::Schema::Argument)
          [
            Graphene::Schema::Argument.new(
              name: "reason",
              type: Graphene::Type::String.new,
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
end