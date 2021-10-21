require "../../spec_helper"

describe Graphene::Validation::FragmentNameUniqueness do
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

    schema = Graphene::Schema.new(
      query: Graphene::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphene::Validation::FragmentNameUniqueness.new(schema)

    query = Graphene::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphene::Validation::Error.new("multiple fragments defined with the name fragmentOne"))
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

    schema = Graphene::Schema.new(
      query: Graphene::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphene::Validation::FragmentNameUniqueness.new(schema)

    query = Graphene::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end
end