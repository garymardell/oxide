require "../../spec_helper"

describe Graphene::Validation::VariablesAreInputTypes do
  it "gives an error if variable is not an input type" do
    query_string = <<-QUERY
      query takesCat($cat: Cat) {
        dog {
          name
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::VariablesAreInputTypes.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Variable \"cat\" must be an input type"))
  end
end