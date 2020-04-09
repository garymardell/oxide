require "../spec_helper"

describe Graphql do
  it "gets object __typename" do
    query_string = <<-QUERY
      query {
        charges {
          id
          __typename
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.to_definition,
      Graphql::Query.new(query_string)
    )

    # pp DummySchema.to_definition

    result = runtime.execute

    result.should eq({ "charges" => [{ "id" => "1", "__typename" => "Charge" }, { "id" => "2", "__typename" => "Charge" }] })
  end
end