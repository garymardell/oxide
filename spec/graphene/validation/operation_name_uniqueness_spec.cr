require "../../spec_helper"

describe Graphene::Validation::OperationNameUniqueness do
  it "checks for operation name uniqueness" do
    query_string = <<-QUERY
      query getName {
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
      query: Graphene::Types::Object.new(
        name: "Query",
        resolver: NullResolver.new
      )
    )

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      schema,
      query,
      [Graphene::Validation::OperationNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should eq([Graphene::Validation::Error.new("multiple operations found with the name getName")])
  end
end