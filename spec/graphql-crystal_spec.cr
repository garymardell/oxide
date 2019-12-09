require "./spec_helper"

class Charge
  property id : Int32
  property status : String

  def initialize(@id, @status)
  end
end

class QueryResolver < Graphql::Schema::Resolver
  def resolve(object, field_name)
    case field_name
    when "charge"
      Charge.new(id: 1, status: "pending")
    when "charges"
      [
        Charge.new(id: 1, status: "paid"),
        Charge.new(id: 2, status: "pending")
      ]
    end
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  def resolve(object : Charge, field_name)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    end
  end
end

describe Graphql do
  it "works" do
    charge = Graphql::Schema::Object.new(
      resolver: ChargeResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "id",
          type: Graphql::Schema::IdType.new
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

    schema = Graphql::Schema.new(
      query: Graphql::Schema::Object.new(
        resolver: QueryResolver.new,
        fields: [
          Graphql::Schema::Field.new(
            name: "charge",
            type: Graphql::Schema::NonNull.new(of_type: charge),
            arguments: [
              Graphql::Schema::Argument.new(
                name: "id"
              )
            ]
          ),
          Graphql::Schema::Field.new(
            name: "charges",
            type: Graphql::Schema::NonNull.new(
              of_type: Graphql::Schema::List.new(of_type: charge)
            )
          )
        ]
      ),
      mutation: nil
    )

    query = Graphql::Language::Nodes::Document.new(
      definitions: [
        Graphql::Language::Nodes::OperationDefinition.new(
          operation_type: "query",
          selections: [
            Graphql::Language::Nodes::Field.new(
              name: "charge",
              selections: [
                Graphql::Language::Nodes::Field.new(
                  name: "id"
                ),
                Graphql::Language::Nodes::Field.new(
                  name: "status"
                )
              ]
            ),
            Graphql::Language::Nodes::Field.new(
              name: "charges",
              selections: [
                Graphql::Language::Nodes::Field.new(
                  name: "id"
                )
              ]
            )
          ]
        )
      ]
    )

    runtime = Graphql::Execution::Interpreter::Runtime.new(
      schema,
      query
    )

    puts runtime.execute
  end
end
