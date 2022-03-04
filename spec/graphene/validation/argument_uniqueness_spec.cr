require "../../spec_helper"

describe Graphene::Validation::ArgumentUniqueness do
  it "gives an error if when selecting multiple arguments with the same name" do
    query_string = <<-QUERY
      query {
        dog(name: "George", name: 1) {
          nickname
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::ArgumentUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("There can be only one argument named \"name\""))
  end
end