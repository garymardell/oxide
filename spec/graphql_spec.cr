require "./spec_helper"

describe Graphql do
  it "executes" do
    query = Graphql::Query.new("query { charges { id } }")

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      query
    )

    result = runtime.execute

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }] })
  end
end
