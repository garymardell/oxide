require "../spec_helper"

describe Oxide::Query do
  it "parses from a json payload" do
    input = <<-JSON
    {
      "query": "{ posts }",
      "variables": {
        "id": "12345"
      },
      "operationName": "test"
    }
    JSON

    query = Oxide::Query.from_json(input)

    query.query_string.should eq("{ posts }")
    query.variables.should eq({ "id" => JSON::Any.new("12345") })
    query.operation_name.should eq("test")
  end

  it "parses without variables" do
    input = <<-JSON
    {
      "query": "{ posts }",
      "operationName": "test"
    }
    JSON

    query = Oxide::Query.from_json(input)

    query.query_string.should eq("{ posts }")
    query.variables.should eq({} of String => JSON::Any)
    query.operation_name.should eq("test")
  end

  it "parses without operation name" do
    input = <<-JSON
    {
      "query": "{ posts }",
      "variables": {
        "id": "12345"
      }
    }
    JSON

    query = Oxide::Query.from_json(input)

    query.query_string.should eq("{ posts }")
    query.variables.should eq({ "id" => JSON::Any.new("12345") })
    query.operation_name.should be_nil
  end

  it "serializes a query" do
    expected_query = Oxide::Query.new(
      query_string: "{ posts { id } }",
      variables: { "input" => JSON::Any.new({ "id" => JSON::Any.new("1s") }) },
      operation_name: "posts"
    )

    query = Oxide::Query.from_json(expected_query.to_json)
    query.should eq(expected_query)
  end

  it "serializes a query with new lines" do
    query_string = <<-GRAPHQL
      mutation CreateModel($input: ModelCreateInput!) {
        createModel(input: $input) {
          model {
            id
            name
            singular
            plural
          }
          userErrors {
            message
          }
        }
      }
    GRAPHQL

    expected_query = Oxide::Query.new(
      query_string: query_string,
      variables: { "input" => JSON::Any.new({ "id" => JSON::Any.new("1") }) },
      operation_name: "posts"
    )

    query = Oxide::Query.from_json(expected_query.to_json)
    query.should eq(expected_query)
  end
end