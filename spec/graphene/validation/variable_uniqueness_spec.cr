require "../../spec_helper"

describe Graphene::Validation::VariableUniqueness do
  it "counter example #168" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean, $atOtherHomes: Boolean) {
        dog {
          isHouseTrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::VariableUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("There can only be one variable named \"atOtherHomes\""))
  end

  it "example #169" do
    query_string = <<-QUERY
      query A($atOtherHomes: Boolean) {
        ...HouseTrainedFragment
      }

      query B($atOtherHomes: Boolean) {
        ...HouseTrainedFragment
      }

      fragment HouseTrainedFragment on Query {
        dog {
          isHouseTrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::VariableUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end
end