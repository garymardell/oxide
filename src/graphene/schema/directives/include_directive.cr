module Graphene
  class Schema
    module Directives
      class IncludeDirective < Graphene::Schema::Directive
        def name : String
          "include"
        end

        def arguments : Array(Graphene::Schema::Argument)
          [
            Graphene::Schema::Argument.new(
              name: "if",
              type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::Boolean.new
              )
            )
          ]
        end

        def locations : Array(String)
          ["FIELD", "FRAGMENT_SPREAD", "INLINE_FRAGMENT"]
        end

        def include?(object, context, argument_values) : Bool
          !!argument_values["if"]
        end
      end
    end
  end
end