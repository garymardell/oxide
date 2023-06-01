require "../../spec_helper"

describe Graphene::Validation::FieldSelections do
  it "counter example #115" do
    query_string = <<-QUERY
      fragment fieldNotDefined on Dog {
        meowVolume
      }

      fragment aliasedLyingFieldTargetNotDefined on Dog {
        barkVolume: kawVolume
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(2)
    pipeline.errors.should contain(Graphene::Error.new("Field \"meowVolume\" does not exist on \"Dog\""))
    pipeline.errors.should contain(Graphene::Error.new("Field \"kawVolume\" does not exist on \"Dog\""))
  end

  it "example #116" do
    query_string = <<-QUERY
      fragment interfaceFieldSelection on Pet {
        name
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #117" do
    query_string = <<-QUERY
      fragment definedOnImplementorsButNotInterface on Pet {
        nickname
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Field \"nickname\" does not exist on \"Pet\""))
  end

  it "example #118" do
    query_string = <<-QUERY
      fragment inDirectFieldSelectionOnUnion on CatOrDog {
        __typename
        ... on Pet {
          name
        }
        ... on Dog {
          barkVolume
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #119" do
    query_string = <<-QUERY
      fragment directFieldSelectionOnUnion on CatOrDog {
        name
        barkVolume
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(2)
    pipeline.errors.should contain(Graphene::Error.new("Field \"name\" can not be selected on union type \"CatOrDog\""))
  end
end