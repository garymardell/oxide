require "../../spec_helper"

describe Graphene::Validation::LeafFieldSelections do
  it "example #126" do
    query_string = <<-QUERY
      fragment scalarSelection on Dog {
        barkVolume
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::LeafFieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #127" do
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
    pipeline.errors.should contain(Graphene::Error.new("Selections can't be made on scalars (field 'barkVolume' returns Int but has selections [sinceWhen])"))
  end

  it "counter example #129" do
    query_string = <<-QUERY
      query directQueryOnObjectWithoutSubFields {
        human
      }

      query directQueryOnInterfaceWithoutSubFields {
        pet
      }

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

    pipeline.errors.size.should eq(3)
    pipeline.errors.should contain(Graphene::Error.new("Field must have selections (field 'human' returns Human but has no selections. Did you mean 'human { ... }'?)"))
    pipeline.errors.should contain(Graphene::Error.new("Field must have selections (field 'pet' returns Pet but has no selections. Did you mean 'pet { ... }'?)"))
    pipeline.errors.should contain(Graphene::Error.new("Field must have selections (field 'catOrDog' returns CatOrDog but has no selections. Did you mean 'catOrDog { ... }'?)"))
  end

  it "example #130" do
    query_string = <<-QUERY
      query directQueryOnObjectWithSubFields {
        human {
          name
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

    pipeline.errors.size.should eq(0)
  end
end