require "./type_type"
require "./directive_type"

module Graphene
  module Introspection
    SchemaType = Graphene::Types::Object.new(
      name: "__Schema",
      resolver: SchemaResolver.new,
      fields: [
        Graphene::Schema::Field.new(
          name: "types",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::List.new(
              of_type: Graphene::Types::NonNull.new(
                of_type: Graphene::Types::LateBound.new("__Type")
              )
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "queryType",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::LateBound.new("__Type")
          )
        ),
        Graphene::Schema::Field.new(
          name: "mutationType",
          type: Graphene::Types::LateBound.new("__Type")
        ),
        Graphene::Schema::Field.new(
          name: "subscriptionType",
          type: Graphene::Types::LateBound.new("__Type")
        ),
        Graphene::Schema::Field.new(
          name: "directives",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::List.new(
              of_type: Graphene::Types::NonNull.new(
                of_type: Graphene::Types::LateBound.new("__Directive")
              )
            )
          )
        )
      ]
    )
  end
end
