require "../../spec_helper"

describe Graphene::Validation::ArgumentNames do
  it "example #131" do
    query_string = <<-QUERY
      fragment argOnRequiredArg on Dog {
        doesKnowCommand(dogCommand: SIT)
      }

      fragment argOnOptional on Dog {
        isHouseTrained(atOtherHomes: true) @include(if: true)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::ArgumentNames.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute
    pipeline.errors.should be_empty
  end

  it "counter example #132" do
    query_string = <<-QUERY
      fragment invalidArgName on Dog {
        doesKnowCommand(command: CLEAN_UP_HOUSE)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::ArgumentNames.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Unknown argument \"command\" on field \"Dog.doesKnowCommand\""))
  end

  it "counter example #133" do
    query_string = <<-QUERY
      fragment invalidArgName on Dog {
        isHouseTrained(atOtherHomes: true) @include(unless: false)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::ArgumentNames.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Unknown argument \"unless\" on directive \"include\""))
  end

  # TODO: example #135
end