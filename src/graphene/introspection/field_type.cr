require "./type_type"
require "./input_value_type"

module Graphene
  module Introspection
    FieldType = Graphene::Types::ObjectType.new(
      name: "__Field",
      resolver: FieldResolver.new,
      fields: {
        "name" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        "description" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        ),
        "args" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::ListType.new(
              of_type: Graphene::Types::NonNullType.new(
                of_type: Graphene::Types::LateBoundType.new("__InputValue")
              )
            )
          )
        ),
        "type" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::LateBoundType.new("__Type")
          )
        ),
        "isDeprecated" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::BooleanType.new
          )
        ),
        "deprecationReason" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        )
      }
    )
  end
end