require "../../spec_helper"

describe Oxide::Validation::DirectivesAreInValidLocations do
  it "counter example #165" do
    query_string = <<-QUERY
      query @skip(if: $foo) {
        field
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::DirectivesAreInValidLocations.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Directive \"@skip\" may not be used on queries."))
  end
end