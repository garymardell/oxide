require "./type_type"
require "./input_value_type"

module Graphene
  module Introspection
    FieldType = Graphene::Types::Object.new(
      name: "__Field",
      resolver: FieldResolver.new,
      fields: [
        Graphene::Field.new(
          name: "name",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::String.new
          )
        ),
        Graphene::Field.new(
          name: "description",
          type: Graphene::Types::String.new
        ),
        Graphene::Field.new(
          name: "args",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::List.new(
              of_type: Graphene::Types::NonNull.new(
                of_type: Graphene::Types::LateBound.new("__InputValue")
              )
            )
          )
        ),
        Graphene::Field.new(
          name: "type",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::LateBound.new("__Type")
          )
        ),
        Graphene::Field.new(
          name: "isDeprecated",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::Boolean.new
          )
        ),
        Graphene::Field.new(
          name: "deprecationReason",
          type: Graphene::Types::String.new
        )
      ]
    )
  end
end