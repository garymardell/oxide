require "../../spec_helper"

describe Oxide::Validation::FieldSelections do
  it "counter example #115" do
    query_string = <<-QUERY
      fragment fieldNotDefined on Dog {
        meowVolume
      }

      fragment aliasedLyingFieldTargetNotDefined on Dog {
        barkVolume: kawVolume
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelections.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
    runtime.errors.should contain(Oxide::ValidationError.new("Field 'meowVolume' doesn't exist on type 'Dog'"))
    runtime.errors.should contain(Oxide::ValidationError.new("Field 'kawVolume' doesn't exist on type 'Dog'"))
  end

  it "example #116" do
    query_string = <<-QUERY
      fragment interfaceFieldSelection on Pet {
        name
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelections.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #117" do
    query_string = <<-QUERY
      fragment definedOnImplementorsButNotInterface on Pet {
        nickname
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelections.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Field 'nickname' doesn't exist on type 'Pet'"))
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

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelections.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #119" do
    query_string = <<-QUERY
      fragment directFieldSelectionOnUnion on CatOrDog {
        name
        barkVolume
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelections.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
    runtime.errors.should contain(Oxide::ValidationError.new("Selections can't be made directly on unions (see selections on CatOrDog)"))
  end
end