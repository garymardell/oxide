require "../../spec_helper"

describe Graphene::Validation::DirectivesAreDefined do
  it "counter example" do
    query_string = <<-QUERY
      query {
        dog @missing {
          isHouseTrained
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::DirectivesAreDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Directive @missing is not defined"))
  end

  it "example" do
    query_string = <<-QUERY
      query {
        dog {
          isHouseTrained @include(if: true)
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::DirectivesAreDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end
end