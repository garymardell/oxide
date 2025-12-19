require "./type_type"
require "./directive_type"

module Oxide
  module Introspection
    SchemaType = Oxide::Types::ObjectType.new(
      name: "__Schema",
      fields: {
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { nil } # TODO: Support descriptions
        ),
        "types" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Type")
              )
            )
          ),
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { object.types }
        ),
        "queryType" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { object.query }
        ),
        "mutationType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type"),
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { object.mutation }
        ),
        "subscriptionType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type"),
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { object.subscription }
        ),
        "directives" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Directive")
              )
            )
          ),
          resolve: ->(object : Oxide::Schema, resolution : Oxide::Resolution) { object.directives }
        )
      }
    )
  end
end
