require "../../spec_helper"

describe Graphql::Validation::DocumentValidator do
  it "does not return an error if operation definition" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    query = Graphql::Query.new(query_string)

    result = Graphql::Validation::DocumentValidator.validate(DummySchema, query)

    result.should be_empty
  end
end