require "../../spec_helper"

describe Graphene::Validation::DirectivesAreUniquePerLocation do
  it "counter example #166" do
    query_string = <<-QUERY
      query ($foo: Boolean = true, $bar: Boolean = false) {
        field @skip(if: $foo) @skip(if: $bar)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::DirectivesAreUniquePerLocation.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("The directive \"skip\" can only be used once at this location."))
  end

  it "example #167" do
    query_string = <<-QUERY
      query ($foo: Boolean = true, $bar: Boolean = false) {
        field @skip(if: $foo) {
          subfieldA
        }
        field @skip(if: $bar) {
          subfieldB
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::DirectivesAreUniquePerLocation.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end
end