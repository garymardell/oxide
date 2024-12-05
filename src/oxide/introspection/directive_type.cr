require "./input_value_type"

module Oxide
  module Introspection
    DirectiveLocationType = Oxide::Types::EnumType.new(
      name: "__DirectiveLocation",
      values: [
        Oxide::Types::EnumValue.new(name: "QUERY"),
        Oxide::Types::EnumValue.new(name: "MUTATION"),
        Oxide::Types::EnumValue.new(name: "SUBSCRIPTION"),
        Oxide::Types::EnumValue.new(name: "FIELD"),
        Oxide::Types::EnumValue.new(name: "FRAGMENT_DEFINITION"),
        Oxide::Types::EnumValue.new(name: "FRAGMENT_SPREAD"),
        Oxide::Types::EnumValue.new(name: "INLINE_FRAGMENT"),
        Oxide::Types::EnumValue.new(name: "SCHEMA"),
        Oxide::Types::EnumValue.new(name: "SCALAR"),
        Oxide::Types::EnumValue.new(name: "OBJECT"),
        Oxide::Types::EnumValue.new(name: "FIELD_DEFINITION"),
        Oxide::Types::EnumValue.new(name: "ARGUMENT_DEFINITION"),
        Oxide::Types::EnumValue.new(name: "INTERFACE"),
        Oxide::Types::EnumValue.new(name: "UNION"),
        Oxide::Types::EnumValue.new(name: "ENUM"),
        Oxide::Types::EnumValue.new(name: "ENUM_VALUE"),
        Oxide::Types::EnumValue.new(name: "INPUT_OBJECT"),
        Oxide::Types::EnumValue.new(name: "INPUT_FIELD_DEFINITION")
      ]
    )

    DirectiveType = Oxide::Types::ObjectType.new(
      name: "__Directive",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::StringType.new
          ),
          resolve: ->(object : Directive, resolution : Oxide::Resolution) { object.name }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Directive, resolution : Oxide::Resolution) { nil }
        ),
        "locations" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: DirectiveLocationType
              )
            )
          ),
          resolve: ->(object : Directive, resolution : Oxide::Resolution) { object.locations.map(&.to_s) }
        ),
        "args" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(
                of_type: Oxide::Types::LateBoundType.new("__InputValue")
              )
            )
          ),
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          resolve: ->(object : Directive, resolution : Oxide::Resolution) {
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
        "isRepeatable" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::BooleanType.new
          ),
          resolve: ->(object : Directive, resolution : Oxide::Resolution) { object.repeatable }
        )
      }
    )
  end
end