require "../../spec_helper"

describe Oxide::Validation::DirectivesAreDefined do
  it "counter example" do
    query_string = <<-QUERY
      query {
        dog @missing {
          isHouseTrained
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::DirectivesAreDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Directive @missing is not defined"))
  end

  it "example" do
    query_string = <<-QUERY
      query {
        dog {
          isHouseTrained @include(if: true)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::DirectivesAreDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end