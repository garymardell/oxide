module Oxide
  module Introspection
    EnumValueType = Oxide::Types::ObjectType.new(
      name: "__EnumValue",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          ),
          resolve: ->(value : Types::EnumValue) { value.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(value : Types::EnumValue) { value.description }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(value : Types::EnumValue) { value.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(value : Types::EnumValue) { value.deprecation_reason }
        )
      }
    )
  end
end