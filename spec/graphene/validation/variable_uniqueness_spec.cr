require "../../spec_helper"

describe Graphene::Validation::VariableUniqueness do
  it "gives an error if multiple variables defined on an operation with the same name" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean, $atOtherHomes: Boolean) {
        dog {
          isHousetrained(atOtherHomes: $atOtherHomes)
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
      [Graphene::Validation::VariableUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("multiple variables defined with the name atOtherHomes"))
  end

  it "does not give an error if variable name is used once" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean) {
        dog {
          isHousetrained(atOtherHomes: $atOtherHomes)
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
      [Graphene::Validation::VariableUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.should be_empty
  end

  it "does not give an error if multiple operations use the same name" do
    query_string = <<-QUERY
      query A($atOtherHomes: Boolean) {
        ...HouseTrainedFragment
      }

      query B($atOtherHomes: Boolean) {
        ...HouseTrainedFragment
      }

      fragment HouseTrainedFragment on Dog {
        dog {
          isHousetrained(atOtherHomes: $atOtherHomes)
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
      [Graphene::Validation::VariableUniqueness.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.should be_empty
  end
end