require "../../src/graphql"
require "./models/*"
require "./resolvers/*"

ChargeType = Graphql::Type::Object.new(
  typename: "Charge",
  resolver: ChargeResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "id",
      type: Graphql::Type::Id.new
    ),
    Graphql::Schema::Field.new(
      name: "status",
      type: Graphql::Type::Enum.new(
        values: [
          Graphql::Type::EnumValue.new(name: "PENDING", value: "pending"),
          Graphql::Type::EnumValue.new(name: "PAID", value: "paid")
        ]
      )
    )
  ]
)

DummySchema = Graphql::Schema.new(
  query: Graphql::Type::Object.new(
    typename: "Query",
    resolver: QueryResolver.new,
    fields: [
      Graphql::Schema::Field.new(
        name: "charge",
        type: Graphql::Type::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphql::Schema::Argument.new(
            name: "id",
            type: Graphql::Type::Id.new
          )
        ]
      ),
      Graphql::Schema::Field.new(
        name: "charges",
        type: Graphql::Type::NonNull.new(
          of_type: Graphql::Type::List.new(of_type: ChargeType)
        )
      )
    ]
  ),
  mutation: nil
)