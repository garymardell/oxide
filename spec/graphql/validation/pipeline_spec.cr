require "../../spec_helper"

describe Graphql::Validation::Pipeline do
  it "executes" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    query = Graphql::Query.new(query_string)

    pipeline = Graphql::Validation::Pipeline.new(DummySchema.compile, query)
    pipeline.execute
  end
end