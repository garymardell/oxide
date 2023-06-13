require "./type_type"
require "./input_value_type"

module Oxide
  module Introspection
    FieldType = Oxide::Types::ObjectType.new(
      name: "__Field",
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
        "args" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__InputValue")
              )
            )
          )
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          )
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          )
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new
        )
      }
    )
  end
end