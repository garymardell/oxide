require "../spec_helper"

describe Graphql do
  it "executes" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }] })
  end

  it "supports unions", focus: false do
    query_string = <<-QUERY
      query {
        transactions {
          id
          status

          ... on Refund {
            partial
          }
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "transactions" => [{ "id" => "1", "status" => "PAID" }, { "id" => "32", "status" => "REFUNDED", "partial" => true }] })
  end

  it "supports fragment spread and variables", focus: false do
    query_string = <<-QUERY
      fragment ChargeInfo on Charge {
        id
      }

      query($id: ID! = 1) {
        charge(id: $id) {
          ...ChargeInfo
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "charge" => { "id" => "1" } })
  end

  it "supports arguments", focus: false do
    query_string = <<-QUERY
      query($id: ID!) {
        charge(id: $id) {
          id
        }
      }
    QUERY

    variables = {
      "id" => "10".as(JSON::Any::Type)
    }

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(
        query_string,
        variables
      )
    )

    result = runtime.execute

    result.should eq({ "charge" => { "id" => "10" } })
  end

  it "supports arguments with default values", focus: false do
    query_string = <<-QUERY
      query($id: ID! = 1) {
        charge(id: $id) {
          id
        }
      }
    QUERY

    variables = {} of String => JSON::Any::Type

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(
        query_string,
        variables
      )
    )

    result = runtime.execute

    result.should eq({ "charge" => { "id" => "1" } })
  end

  it "supports dynamically generated schema" do
    fields = [
      "foo",
      "bar"
    ]

    query_type = Graphql::Type::Object.new(
      typename: "DynamicQuery",
      resolver: DynamicResolver.new,
      fields: fields.map do |field_name|
        Graphql::Schema::Field.new(
          name: field_name,
          type: Graphql::Type::String.new
        )
      end
    )

    schema = Graphql::Schema.new(query: query_type)

    query_string = <<-QUERY
      query {
        foo
        bar
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      schema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "foo" => "foo", "bar" => "bar" })
  end
end