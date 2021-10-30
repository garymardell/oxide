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
      query: Graphene::Types::Object.new(
        name: "Query"
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::FragmentsMustBeUsed.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("fragment unusedFragment is defined but not used"))
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
      query: Graphene::Types::Object.new(
        name: "Query"
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::FragmentsMustBeUsed.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.should be_empty
  end
end