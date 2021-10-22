require "./type_type"
require "./directive_type"

module Graphene
  module Introspection
    SchemaType = Graphene::Type::Object.new(
      name: "__Schema",
      fields: [
        Graphene::Schema::Field.new(
          name: "types",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::List.new(
              of_type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::LateBound.new("__Type")
              )
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "queryType",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::LateBound.new("__Type")
          )
        ),
        Graphene::Schema::Field.new(
          name: "mutationType",
          type: Graphene::Type::LateBound.new("__Type")
        ),
        Graphene::Schema::Field.new(
          name: "subscriptionType",
          type: Graphene::Type::LateBound.new("__Type")
        ),
        Graphene::Schema::Field.new(
          name: "directives",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::List.new(
              of_type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::LateBound.new("__Directive")
              )
            )
          )
        )
      ]
    )
  end
end
