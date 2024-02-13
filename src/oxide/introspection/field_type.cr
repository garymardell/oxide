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
          resolve: ->(field : FieldInfo) { field.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(field : FieldInfo) { field.description }
        ),
        "args" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__InputValue")
              )
            )
          ),
          resolve: ->(field : FieldInfo) { field.arguments.map { |name, argument| Introspection::ArgumentInfo.new(name, argument) } }
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(field : FieldInfo) { field.type }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(field : FieldInfo) { field.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(field : FieldInfo) { field.deprecation_reason }
        )
      }
    )
  end
end