require "./type_type"

module Graphene
  module Introspection
    InputValueType = Graphene::Type::Object.new(
      typename: "__InputValue",
      resolver: InputValueResolver.new,
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
          name: "type",
          type: Graphene::Type::NonNull.new(
            of_type: Graphene::Type::LateBound.new("__Type")
          )
        ),
        Graphene::Schema::Field.new(
          name: "defaultValue",
          type: Graphene::Type::String.new
        )
      ]
    )
  end
end