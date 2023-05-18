require "./type_type"
require "./directive_type"

module Graphene
  module Introspection
    SchemaType = Graphene::Types::ObjectType.new(
      name: "__Schema",
      resolver: DefaultResolver.new,
      fields: {
        "types" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__Type")
              )
            )
          )
        ),
        "queryType" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::LateBoundType.new("__Type")
          )
        ),
        "mutationType" => Graphene::Field.new(
          type: Graphene::Types::LateBoundType.new("__Type")
        ),
        "subscriptionType" => Graphene::Field.new(
          type: Graphene::Types::LateBoundType.new("__Type")
        ),
        "directives" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__Directive")
              )
            )
          )
        )
      }
    )
  end
end
