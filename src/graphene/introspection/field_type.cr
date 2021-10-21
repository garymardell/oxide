require "./type_type"
require "./input_value_type"

module Graphene
  module Introspection
    FieldType = Graphene::Type::Object.new(
      typename: "__Field",
      resolver: FieldResolver.new,
      fields: [
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::String.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Type::String.new
        ),
        Graphene::Schema::Field.new(
          name: "args",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::List.new(
              of_type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::LateBound.new("__InputValue")
              )
            )
          )
        ),
        Graphene::Schema::Field.new(
          name: "type",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::LateBound.new("__Type")
          )
        ),
        Graphene::Schema::Field.new(
          name: "isDeprecated",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::Boolean.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "deprecationReason",
          type: Graphene::Type::String.new
        )
      ]
    )
  end
end