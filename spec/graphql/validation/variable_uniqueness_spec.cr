require "../../spec_helper"

describe Graphql::Validation::VariableUniqueness do
  it "gives an error if multiple variables defined on an operation with the same name" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean, $atOtherHomes: Boolean) {
        dog {
          isHousetrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::VariableUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should contain(Graphql::Validation::Error.new("multiple variables defined with the name atOtherHomes"))
  end

  it "does not give an error if variable name is used once" do
    query_string = <<-QUERY
      query houseTrainedQuery($atOtherHomes: Boolean) {
        dog {
          isHousetrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::VariableUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
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

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::VariableUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.should be_empty
  end
end