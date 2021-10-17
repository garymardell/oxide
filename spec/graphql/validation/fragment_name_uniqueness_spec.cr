require "../../spec_helper"

describe Graphql::Validation::FragmentNameUniqueness do
  it "gives an error if multiple fragments defined with the same name" do
    query_string = <<-QUERY
      {
        dog {
          ...fragmentOne
        }
      }

      fragment fragmentOne on Dog {
        name
      }

      fragment fragmentOne on Dog {
        owner {
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

    rule = Graphql::Validation::FragmentNameUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphql::Validation::Error.new("multiple fragments defined with the name fragmentOne"))
  end

  it "does not give an error if fragments are defined with unique names" do
    query_string = <<-QUERY
      {
        dog {
          ...fragmentOne
          ...fragmentTwo
        }
      }

      fragment fragmentOne on Dog {
        name
      }

      fragment fragmentTwo on Dog {
        owner {
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

    rule = Graphql::Validation::FragmentNameUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end
end