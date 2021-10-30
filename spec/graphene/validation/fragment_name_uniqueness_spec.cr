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
      query: Graphene::Types::Object.new(
        name: "Query",
        resolver: NullResolver.new
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::FragmentNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("multiple fragments defined with the name fragmentOne"))
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
      query: Graphene::Types::Object.new(
        name: "Query",
        resolver: NullResolver.new
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::FragmentNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.should be_empty
  end
end