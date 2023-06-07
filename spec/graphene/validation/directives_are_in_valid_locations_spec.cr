require "../../spec_helper"

describe Graphene::Validation::DirectivesAreInValidLocations do
  it "counter example #165" do
    query_string = <<-QUERY
      query @skip(if: $foo) {
        field
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::DirectivesAreInValidLocations.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("'@skip' can't be applied to queries (allowed: fields, fragment spreads, inline fragments)"))
  end
end