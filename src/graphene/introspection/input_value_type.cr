require "./type_type"

module Graphene
  module Introspection
    InputValueType = Graphene::Types::Object.new(
      name: "__InputValue",
      fields: [
        Graphene::Schema::Field.new(
          name: "name",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::String.new
          )
        ),
        Graphene::Schema::Field.new(
          name: "description",
          type: Graphene::Types::String.new
        ),
        Graphene::Schema::Field.new(
          name: "type",
          type: Graphene::Types::NonNull.new(
            of_type: Graphene::Types::LateBound.new("__Type")
          )
        ),
        Graphene::Schema::Field.new(
          name: "defaultValue",
          type: Graphene::Types::String.new
        )
      ]
    )
  end
end