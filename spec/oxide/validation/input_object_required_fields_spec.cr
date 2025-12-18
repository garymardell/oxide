require "../../spec_helper"

describe Oxide::Validation::InputObjectRequiredFields do
  it "valid input object with all required fields" do
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
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "valid input object with optional fields omitted" do
    query_string = <<-QUERY
      {
        findDog(searchBy: { owner: "John" }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "invalid - missing required field" do
    query_string = <<-QUERY
      mutation {
        addPet(pet: { cat: {} }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be > 0
    runtime.errors.first.message.not_nil!.should contain("name")
    runtime.errors.first.message.not_nil!.should contain("required")
  end

  it "invalid - null value for required field" do
    query_string = <<-QUERY
      mutation {
        addPet(pet: { cat: { name: null } }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.not_nil!.should contain("name")
    runtime.errors.first.message.not_nil!.should contain("cannot be null")
  end

  it "valid - nested input objects with all required fields" do
    query_string = <<-QUERY
      mutation {
        addPet(pet: { cat: { name: "Fluffy" } }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "valid - input object in variable default value" do
    query_string = <<-QUERY
      query($search: FindDogInput = { name: "Buddy" }) {
        findDog(searchBy: $search) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::InputObjectRequiredFields.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end