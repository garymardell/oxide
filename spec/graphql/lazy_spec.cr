require "../spec_helper"

describe Graphql do
  it "executes lazy" do
    query_string = <<-QUERY
      query {
        charges {
          id
          receipt {
            id
          }
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charges" => [
      { "id" => "1", "receipt" => { "id" => "1" } },
      { "id" => "2", "receipt" => { "id" => "2" } },
      { "id" => "3", "receipt" => { "id" => "3" } }
    ]})
  end
end