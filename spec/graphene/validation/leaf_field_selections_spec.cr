require "../../spec_helper"

describe Graphene::Validation::LeafFieldSelections do
  it "gives an error if subselecting on leaf field" do
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
    pipeline.errors.should contain(Graphene::Error.new("Cannot select fields on leaf field \"barkVolume\""))
  end

  it "gives an error if no subselection on object" do
    query_string = <<-QUERY
      query directQueryOnObjectWithoutSubFields {
        human
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
    pipeline.errors.should contain(Graphene::Error.new("Non leaf fields must have a field subselection"))
  end

  it "gives an error if no subselection on interface" do
    query_string = <<-QUERY
      query directQueryOnInterfaceWithoutSubFields {
        pet
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
    pipeline.errors.should contain(Graphene::Error.new("Non leaf fields must have a field subselection"))
  end

  it "gives an error if no subselection on union" do
    query_string = <<-QUERY
      query directQueryOnUnionWithoutSubFields {
        catOrDog
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
    pipeline.errors.should contain(Graphene::Error.new("Non leaf fields must have a field subselection"))
  end
end