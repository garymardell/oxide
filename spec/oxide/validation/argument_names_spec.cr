require "../../spec_helper"

describe Oxide::Validation::ArgumentNames do
  it "example #131" do
    query_string = <<-QUERY
      fragment argOnRequiredArg on Dog {
        doesKnowCommand(dogCommand: SIT)
      }

      fragment argOnOptional on Dog {
        isHouseTrained(atOtherHomes: true) @include(if: true)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ArgumentNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "counter example #132" do
    query_string = <<-QUERY
      fragment invalidArgName on Dog {
        doesKnowCommand(command: CLEAN_UP_HOUSE)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ArgumentNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Unknown argument \"command\" on field \"Dog.doesKnowCommand\". Did you mean \"dogCommand\"?", [Oxide::Location.new(2, 21)]))
  end

  it "counter example #133" do
    query_string = <<-QUERY
      fragment invalidArgName on Dog {
        isHouseTrained(atOtherHomes: true) @include(unless: false)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ArgumentNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Unknown argument \"unless\" on directive \"@include\"."))
  end

  it "example #135" do
    query_string = <<-QUERY
      fragment multipleArgs on Arguments {
        multipleRequirements(x: 1, y: 2)
      }

      fragment multipleArgsReverseOrder on Arguments {
        multipleRequirements(y: 2, x: 1)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ArgumentNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end