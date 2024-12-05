require "./type_type"

module Oxide
  module Introspection
    InputValueType = Oxide::Types::ObjectType.new(
      name: "__InputValue",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          ),
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) { object.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) { object.description }
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) { object.type }
        ),
        "defaultValue" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) {
            # TODO: Support printing all types
            if default_value = object.default_value
              case default_value
              when String
                "\"#{default_value}\""
              else
                default_value
              end
            end
          }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) { object.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : ArgumentInfo, resolution : Oxide::Resolution) { object.deprecation_reason }
        )
      }
    )
  end
end