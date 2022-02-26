require "./type_type"
require "./input_value_type"

module Graphene
  module Introspection
    FieldType = Graphene::Types::ObjectType.new(
      name: "__Field",
      resolver: FieldResolver.new,
      fields: [
        Graphene::Field.new(
          name: "name",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        Graphene::Field.new(
          name: "description",
          type: Graphene::Types::StringType.new
        ),
        Graphene::Field.new(
          name: "args",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__InputValue")
              )
            )
          )
        ),
        Graphene::Field.new(
          name: "type",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::LateBoundType.new("__Type")
          )
        ),
        Graphene::Field.new(
          name: "isDeprecated",
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::BooleanType.new
          )
        ),
        Graphene::Field.new(
          name: "deprecationReason",
          type: Graphene::Types::StringType.new
        )
      ]
    )
  end
end