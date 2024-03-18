require "./type_type"
require "./input_value_type"

module Oxide
  module Introspection
    FieldType = Oxide::Types::ObjectType.new(
      name: "__Field",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          ),
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.description }
        ),
        "args" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__InputValue")
              )
            )
          ),
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.arguments.map { |name, argument| Introspection::ArgumentInfo.new(name, argument) } }
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.type }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(resolution : Oxide::Resolution(FieldInfo)) { resolution.object.deprecation_reason }
        )
      }
    )
  end
end