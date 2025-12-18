require "../../spec_helper"

describe Oxide::Validation::ValuesOfCorrectType do
  it "example #160" do
    query_string = <<-QUERY
      fragment goodBooleanArg on Arguments {
        booleanArgField(booleanArg: true)
      }

      fragment coercedIntIntoFloatArg on Arguments {
        # Note: The input coercion rules for Float allow Int literals.
        floatArgField(floatArg: 123)
      }

      query goodComplexDefaultValue($search: FindDogInput = { name: "Fido" }) {
        findDog(searchBy: $search) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ValuesOfCorrectType.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #161" do
    query_string = <<-QUERY
      fragment stringIntoInt on Arguments {
        intArgField(intArg: "123")
      }

      query badComplexValue {
        findDog(searchBy: { name: 123 }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ValuesOfCorrectType.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
    error_messages = runtime.errors.map(&.message)
    error_messages.should contain("Argument 'intArg' on Field 'intArgField' has an invalid value (\"123\"). Expected type 'Int'.")
    error_messages.should contain("Argument 'name' on InputObject 'FindDogInput' has an invalid value (123). Expected type 'String'.")
  end
end