require "./type_type"

module Oxide
  module Introspection
    InputValueType = Oxide::Types::ObjectType.new(
      name: "__InputValue",
      resolver: DefaultResolver.new,
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          )
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          )
        ),
        "defaultValue" => Oxide::Field.new(
          type: Oxide::Types::StringType.new
        )
      }
    )
  end
end