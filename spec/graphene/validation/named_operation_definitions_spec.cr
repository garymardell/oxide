# For each operation definition operation in the document:
#   -Let operationName be the name of operation.
#   - If operationName exists:
#     - Let operations be all operation definitions in the document named operationName.
#     - operations must be a set of one.

require "../../spec_helper"

describe Graphene::Validation::NamedOperationDefinitions do
  it "gives an error if multiple operation definitions have the same name" do
    query_string = <<-QUERY
      query GetDog {
        dog(name: "George") {
          nickname
        }
      }

      query GetDog {
        dog(name: "Dave") {
          nickname
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::NamedOperationDefinitions.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Multiple operations with the same name"))
  end
end