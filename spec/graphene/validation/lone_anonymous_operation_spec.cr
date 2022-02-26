require "../../spec_helper"

describe Graphene::Validation::LoneAnonymousOperation do
  it "allows a single anonymous operation" do
    query_string = <<-QUERY
    {
      dog {
        name
      }
    }
    QUERY

    schema = Graphene::Schema.new(
      query: Graphene::Types::ObjectType.new(
        name: "Query",
        resolver: NullResolver.new
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::LoneAnonymousOperation.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.should be_empty
  end

  it "checks there is only one anonymous operation defined" do
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

    schema = Graphene::Schema.new(
      query: Graphene::Types::ObjectType.new(
        name: "Query",
        resolver: NullResolver.new
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::LoneAnonymousOperation.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("only one anonymous operation can be defined"))
  end
end