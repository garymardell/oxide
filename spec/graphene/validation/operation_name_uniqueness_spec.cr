require "../../spec_helper"

describe Graphene::Validation::OperationNameUniqueness do
  it "example #105" do
    query_string = <<-QUERY
      query getDogName {
        dog {
          name
        }
      }

      query getOwnerName {
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
      [Graphene::Validation::OperationNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #106" do
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

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::OperationNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Multiple operations with the same name"))
  end

  it "counter example #107" do
    query_string = <<-QUERY
      query dogOperation {
        dog {
          name
        }
      }

      mutation dogOperation {
        mutateDog {
          id
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::OperationNameUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Multiple operations with the same name"))
  end
end