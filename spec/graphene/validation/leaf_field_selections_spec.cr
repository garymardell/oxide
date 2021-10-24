require "../../spec_helper"

describe Graphene::Validation::LeafFieldSelections do
  it "gives an error if selection on scalar type" do
    query_string = <<-QUERY
      fragment scalarSelectionsNotAllowedOnInt on Dog {
        barkVolume {
          sinceWhen
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::LeafFieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("selections on scalar values are not allowed"))
  end

  it "gives an error if no selection on object type" do
    query_string = <<-QUERY
      query directQueryOnObjectWithoutSubFields {
        dog
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::LeafFieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("selection must be provided for dog"))
  end
end