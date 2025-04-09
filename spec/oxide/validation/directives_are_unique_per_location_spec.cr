require "../../spec_helper"

describe Oxide::Validation::DirectivesAreUniquePerLocation do
  it "counter example #166" do
    query_string = <<-QUERY
      query ($foo: Boolean = true, $bar: Boolean = false) {
        field @skip(if: $foo) @skip(if: $bar)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::DirectivesAreUniquePerLocation.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The directive \"skip\" can only be used once at this location."))
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

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::DirectivesAreUniquePerLocation.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end