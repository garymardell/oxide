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
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) { object.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) { object.description }
        ),
        "args" => Oxide::Field.new(
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__InputValue")
              )
            )
          ),
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) {
            if resolution.arguments["includeDeprecated"]?
              object.arguments.map do |name, argument|
                Introspection::ArgumentInfo.new(name, argument)
              end
            else
              object.arguments.reject { |_, argument| argument.deprecated? }.map do |name, argument|
                Introspection::ArgumentInfo.new(name, argument)
              end
            end
          }
        ),
        "type" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          ),
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) { object.type }
        ),
        "isDeprecated" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) { object.deprecated? }
        ),
        "deprecationReason" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : FieldInfo, resolution : Oxide::Resolution) { object.deprecation_reason }
        )
      }
    )
  end
end