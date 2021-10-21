require "../../spec_helper"

describe Graphene::Validation::FragmentsMustBeUsed do
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

    schema = Graphene::Schema.new(
      query: Graphene::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphene::Validation::FragmentsMustBeUsed.new(schema)

    query = Graphene::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphene::Validation::Error.new("fragment unusedFragment is defined but not used"))
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

    schema = Graphene::Schema.new(
      query: Graphene::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphene::Validation::FragmentsMustBeUsed.new(schema)

    query = Graphene::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end
end