require "./field_type"
require "./enum_value_type"
require "./input_value_type"

module Oxide
  module Introspection
    TypeKindType = Oxide::Types::EnumType.new(
      name: "__TypeKind",
      values: [
        Oxide::Types::EnumValue.new(name: "SCALAR"),
        Oxide::Types::EnumValue.new(name: "OBJECT"),
        Oxide::Types::EnumValue.new(name: "INTERFACE"),
        Oxide::Types::EnumValue.new(name: "UNION"),
        Oxide::Types::EnumValue.new(name: "ENUM"),
        Oxide::Types::EnumValue.new(name: "INPUT_OBJECT"),
        Oxide::Types::EnumValue.new(name: "LIST"),
        Oxide::Types::EnumValue.new(name: "NON_NULL")
      ]
    )

    TypeType = Oxide::Types::ObjectType.new(
      name: "__Type",
      fields: {
        "kind" => Oxide::Field.new(
          type: Oxide::Types::NonNullType.new(of_type: TypeKindType),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type.unwrap(info.schema).kind
          }
        ),
        "name" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type.unwrap(info.schema).name
          }
        ),
        "description" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type.unwrap(info.schema).description
          }
        ),
        "fields" => Oxide::Field.new(
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Field") # Introspection::Field
            )
          ),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::ObjectType, Types::InterfaceType
              if arguments["includeDeprecated"]?
                type.fields.map do |name, field|
                  FieldInfo.new(name, field)
                end
              else
                type.fields.reject { |_, field| field.deprecated? }.map do |name, field|
                  FieldInfo.new(name, field)
                end
              end
            end
          }
        ),
        "interfaces" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Type")  # Introspection::Type
            )
          ),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::ObjectType, Types::InterfaceType
              type.interfaces
            end
          }
        ),
        "possibleTypes" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__Type")
            )
          ),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::UnionType
              type.possible_types
            when Types::InterfaceType
              info.schema.not_nil!.type_map.each_with_object([] of Oxide::Type) do |(_, potential), memo|
                if potential.responds_to?(:interfaces) && potential.interfaces.includes?(type)
                  memo << type
                end
              end
            end
          }
        ),
        "enumValues" => Oxide::Field.new(
          arguments: {
            "includeDeprecated" => Oxide::Argument.new(
              type: Oxide::Types::BooleanType.new,
              default_value: false
            )
          },
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Introspection::EnumValueType
            )
          ),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::EnumType
              if arguments["includeDeprecated"]?
                type.values
              else
                type.values.reject(&.deprecated?)
              end
            end
          }
        ),
        "inputFields" => Oxide::Field.new(
          type: Oxide::Types::ListType.new(
            of_type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::LateBoundType.new("__InputValue") # Introspection::InputValue
            )
          ),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::InputObjectType
              type.input_fields.map { |name, argument| ArgumentInfo.new(name, argument) }
            end
          }
        ),
        "ofType" => Oxide::Field.new(
          type: Oxide::Types::LateBoundType.new("__Type"),
          resolve: ->(type : Type, arguments : ArgumentValues, context : Execution::Context, info : Execution::ResolutionInfo) {
            type = type.unwrap(info.schema)

            case type
            when Types::NonNullType, Types::ListType
              type.of_type
            end
          }
        )
      }
    )
  end
end