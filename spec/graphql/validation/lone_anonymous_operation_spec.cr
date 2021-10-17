require "../../spec_helper"

describe Graphql::Validation::LoneAnonymousOperation do
  it "allows a single anonymous operation" do
    query_string = <<-QUERY
    {
      dog {
        name
      }
    }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::LoneAnonymousOperation.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end

  it "checks there is only one anonymous operation defined" do
    query_string = <<-QUERY
      {
        dog {
          name
        }
      }

      query getName {
        dog {
          owner {
            name
          }
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::LoneAnonymousOperation.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphql::Validation::Error.new("only one anonymous operation can be defined"))
  end
end