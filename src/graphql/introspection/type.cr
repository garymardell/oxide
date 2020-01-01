require "./field"
require "./enum_value"
require "./input_value"

module Graphql
  module Introspection
    TypeKind = Graphql::Type::Enum.new(
      values: [
        Graphql::Type::EnumValue.new(name: "SCALAR"),
        Graphql::Type::EnumValue.new(name: "OBJECT"),
        Graphql::Type::EnumValue.new(name: "INTERFACE"),
        Graphql::Type::EnumValue.new(name: "UNION"),
        Graphql::Type::EnumValue.new(name: "ENUM"),
        Graphql::Type::EnumValue.new(name: "INPUT_OBJECT"),
        Graphql::Type::EnumValue.new(name: "LIST"),
        Graphql::Type::EnumValue.new(name: "NON_NULL")
      ]
    )

    Type = Graphql::Type::Object.new(
      typename: "__Type",
      resolver: TypeResolver.new
    )

    Type.add_field(Graphql::Schema::Field.new(
      name: "kind",
      type: Graphql::Type::NonNull.new(of_type: TypeKind)
    ))

    Type.add_field(Graphql::Schema::Field.new(
      name: "name",
      type: Graphql::Type::String.new
    ))

    Type.add_field(Graphql::Schema::Field.new(
      name: "description",
      type: Graphql::Type::String.new
    ))
    Type.add_field(Graphql::Schema::Field.new(
      name: "fields",
      arguments: [
        Graphql::Schema::Argument.new(
          name: "includeDeprecated",
          type: Graphql::Type::Boolean.new,
          default_value: false
        )
      ],
      type: Graphql::Type::List.new(
        of_type: Graphql::Type::NonNull.new(
          of_type: Introspection::Field
        )
      )
    ))
    Type.add_field(Graphql::Schema::Field.new(
      name: "interfaces", # interfaces: [__Type!]
      type: Graphql::Type::List.new(
        of_type: Graphql::Type::NonNull.new(
          of_type: Introspection::Type
        )
      )
    ))
    Type.add_field(Graphql::Schema::Field.new(
      name: "possibleTypes",
      type: Graphql::Type::List.new(
        of_type: Graphql::Type::NonNull.new(
          of_type: Introspection::Type
        )
      )
    ))
    Type.add_field(Graphql::Schema::Field.new(
      name: "enumValues",
      type: Graphql::Type::List.new(
        of_type: Graphql::Type::NonNull.new(
          of_type: Introspection::EnumValue
        )
      )
    ))
    Type.add_field(Graphql::Schema::Field.new(
      name: "inputFields",
      type: Graphql::Type::List.new(
        of_type: Graphql::Type::NonNull.new(
          of_type: Introspection::InputValue
        )
      )
    ))

    Type.add_field(Graphql::Schema::Field.new(
      name: "ofType",
      type: Introspection::Type
    ))
  end
end