require "../../spec_helper"

describe Oxide::Validation::InputObjectFieldUniqueness do
  it "counter example #164" do
    query_string = <<-QUERY
      {
        field(arg: { field: true, field: false })
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectFieldUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("There can be only one input field named \"field\""))
  end
end