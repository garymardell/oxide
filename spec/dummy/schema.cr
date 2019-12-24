require "./models/*"
require "./resolvers/*"

ChargeType = Graphql::Schema::Object.new(
  name: "Charge",
  resolver: ChargeResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "id",
      type: Graphql::Schema::Id.new
    ),
    Graphql::Schema::Field.new(
      name: "status",
      type: Graphql::Schema::Enum.new(
        values: [
          Graphql::Schema::EnumValue.new(name: "PENDING", value: "pending"),
          Graphql::Schema::EnumValue.new(name: "PAID", value: "paid")
        ]
      )
    )
  ]
)

DummySchema = Graphql::Schema.new(
  query: Graphql::Schema::Object.new(
    name: "Query",
    resolver: QueryResolver.new,
    fields: [
      Graphql::Schema::Field.new(
        name: "charge",
        type: Graphql::Schema::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphql::Schema::Argument.new(
            name: "id",
            type: Graphql::Schema::Id.new
          )
        ]
      ),
      Graphql::Schema::Field.new(
        name: "charges",
        type: Graphql::Schema::NonNull.new(
          of_type: Graphql::Schema::List.new(of_type: ChargeType)
        )
      )
    ]
  ),
  mutation: nil
)