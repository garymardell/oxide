require "./type_type"
require "./directive_type"

module Graphene
  module Introspection
    SchemaType = Graphene::Types::ObjectType.new(
      name: "__Schema",
      resolver: SchemaResolver.new,
      fields: [
        Graphene::Field.new(
          name: "types",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__Type")
              )
            )
          )
        ),
        Graphene::Field.new(
          name: "queryType",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::LateBoundType.new("__Type")
          )
        ),
        Graphene::Field.new(
          name: "mutationType",
          type: Graphene::Types::LateBoundType.new("__Type")
        ),
        Graphene::Field.new(
          name: "subscriptionType",
          type: Graphene::Types::LateBoundType.new("__Type")
        ),
        Graphene::Field.new(
          name: "directives",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__Directive")
              )
            )
          )
        )
      ]
    )
  end
end
