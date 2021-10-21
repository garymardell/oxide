require "../../spec_helper"

describe Graphene::Validation::Pipeline do
  it "executes" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(DummySchema, query)
    pipeline.execute
  end
end