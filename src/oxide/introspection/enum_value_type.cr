module Oxide
  module Introspection
    EnumValueType = Oxide::Types::ObjectType.new(
      name: "__EnumValue",
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