module Oxide
  module Introspection
    EnumValueType = Oxide::Types::ObjectType.new(
      name: "__EnumValue",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          ),
          resolve: ->(object : Types::EnumValue, resolution : Oxide::Resolution) { object.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Types::EnumValue, resolution : Oxide::Resolution) { object.description }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(object : Types::EnumValue, resolution : Oxide::Resolution) { object.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Types::EnumValue, resolution : Oxide::Resolution) { object.deprecation_reason }
        )
      }
    )
  end
end