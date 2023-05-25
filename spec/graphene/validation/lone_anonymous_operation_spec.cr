require "../../spec_helper"

describe Graphene::Validation::LoneAnonymousOperation do
  it "gives an error if an anonymous and named operations are both provided" do
    query_string = <<-QUERY
      {
        dog(name: "George") {
          nickname
        }
      }

      query GetDog {
        dog(name: "Dave") {
          nickname
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::LoneAnonymousOperation.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Cannot provide both anonymous and named operations"))
  end
end