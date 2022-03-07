require "./type_type"

module Graphene
  module Introspection
    InputValueType = Graphene::Types::ObjectType.new(
      name: "__InputValue",
      resolver: InputValueResolver.new,
      fields: {
        "name" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::StringType.new
          )
        ),
        "description" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        ),
        "type" => Graphene::Field.new(
          type: Graphene::Types::NonNullType.new(
            of_type: Graphene::Types::LateBoundType.new("__Type")
          )
        ),
        "defaultValue" => Graphene::Field.new(
          type: Graphene::Types::StringType.new
        )
      }
    )
  end
end