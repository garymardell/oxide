require "../../spec_helper"

describe Graphene::Validation::ArgumentNames do
  it "gives an error if argument does not exist on field" do
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

  it "does not give an error if the field is present" do
    query_string = <<-QUERY
      fragment argOnRequiredArg on Dog {
        doesKnowCommand(dogCommand: SIT)
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
end