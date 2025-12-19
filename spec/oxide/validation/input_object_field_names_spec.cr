require "../../spec_helper"

describe Oxide::Validation::InputObjectFieldNames do
  it "example #162" do
    query_string = <<-QUERY
      {
        findDog(searchBy: { name: "Fido" }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectFieldNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #163" do
    query_string = <<-QUERY
      {
        findDog(searchBy: { favoriteCookieFlavor: "Bacon" }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectFieldNames.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("Field \"favoriteCookieFlavor\" is not defined by type \"FindDogInput\"."))
  end
end