require "../../spec_helper"

describe Oxide::Validation::VariableUniqueness do
  it "counter example #168" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean, $atOtherHomes: Boolean) {
        dog {
          isHouseTrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::VariableUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("There can only be one variable named \"atOtherHomes\""))
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

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::VariableUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end