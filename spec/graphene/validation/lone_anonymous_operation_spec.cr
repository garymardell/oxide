require "../../spec_helper"

describe Graphene::Validation::LoneAnonymousOperation do
  it "example #108" do
    query_string = <<-QUERY
      {
        dog {
          name
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

    pipeline.errors.size.should eq(0)
  end

  it "counter example #109" do
    query_string = <<-QUERY
      {
        dog {
          name
        }
      }

      query getName {
        dog {
          owner {
            name
          }
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