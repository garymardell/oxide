require "./type_type"
require "./directive_type"

module Oxide
  module Introspection
    SchemaType = Oxide::Types::ObjectType.new(
      name: "__Schema",
      fields: {
        "types" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Type")
              )
            )
          ),
          resolve: ->(schema : Schema) { schema.types }
        ),
        "queryType" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(schema : Schema) { schema.query }
        ),
        "mutationType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type"),
          resolve: ->(schema : Schema) { schema.mutation }
        ),
        "subscriptionType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type"),
          resolve: ->(schema : Schema) { nil }
        ),
        "directives" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__Directive")
              )
            )
          ),
          resolve: ->(schema : Schema) { schema.directives }
        )
      }
    )
  end
end
