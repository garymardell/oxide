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
          resolve: ->(argument : ArgumentInfo) { argument.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(argument : ArgumentInfo) { argument.description }
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(argument : ArgumentInfo) { argument.type }
        ),
        "defaultValue" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(argument : ArgumentInfo) { argument.default_value }
        )
      }
    )
  end
end