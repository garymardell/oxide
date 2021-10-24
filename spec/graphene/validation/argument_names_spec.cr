require "../../spec_helper"

describe Graphene::Validation::ArgumentNames do
  it "gives an error if argument does not exit on field" do
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
    pipeline.errors.should contain(Graphene::Validation::Error.new("argument command is not valid for doesKnowCommand"))
  end
end