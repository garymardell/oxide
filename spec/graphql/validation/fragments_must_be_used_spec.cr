require "../../spec_helper"

describe Graphql::Validation::FragmentsMustBeUsed do
  it "gives an error if defined fragments are not used" do
    query_string = <<-QUERY
      fragment unusedFragment on Dog {
        meowVolume
      }

      query {
        dog {
          id
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::FragmentsMustBeUsed.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphql::Validation::Error.new("fragment unusedFragment is defined but not used"))
  end

  it "does not give an error if fragment definition is used" do
    query_string = <<-QUERY
      fragment usedFragment on Dog {
        id
      }

      query {
        dog {
          ...usedFragment
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::FragmentsMustBeUsed.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end
end