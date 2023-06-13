require "./type_type"
require "./directive_type"

module Oxide
  module Introspection
    SchemaType = Oxide::Types::ObjectType.new(
      name: "__Schema",
      resolver: DefaultResolver.new,
      fields: {
        "types" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Type")
              )
            )
          )
        ),
        "queryType" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          )
        ),
        "mutationType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type")
        ),
        "subscriptionType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type")
        ),
        "directives" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Directive")
              )
            )
          )
        )
      }
    )
  end
end
