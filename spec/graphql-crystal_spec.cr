require "./spec_helper"

class Charge
  property id : Int32

  def initialize(@id)
  end
end

class QueryResolver < Graphql::Schema::Resolver
  def resolve(object, field_name)
    case field_name
    when "charge"
      Charge.new(id: 1)
    end
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  def resolve(object : Charge, field_name)
    case field_name
    when "id"
      object.id
    end
  end
end

describe Graphql do
  it "works" do
    schema = Graphql::Schema.new(
      query: Graphql::Schema::Object.new(
        resolver: QueryResolver.new,
        fields: [
          Graphql::Schema::Field.new(
            name: "charge",
            type: Graphql::Schema::Object.new(
              resolver: ChargeResolver.new,
              fields: [
                Graphql::Schema::Field.new(
                  name: "id",
                  type: Graphql::Schema::IdType.new,
                  null: false
                )
              ]
            ),
            null: false,
            arguments: [
              Graphql::Schema::Argument.new(
                name: "id"
              )
            ]
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
