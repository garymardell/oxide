require "../../spec_helper"

describe Oxide::Validation::AllVariableUsagesAreAllowed do
  it "allows compatible variable usage" do
    query_string = <<-QUERY
      query ($intArg: Int) {
        arguments {
          intArgField(intArg: $intArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects incompatible variable usage - Int to Boolean" do
    query_string = <<-QUERY
      query ($intArg: Int) {
        arguments {
          booleanArgField(booleanArg: $intArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/intArg.*Int.*Boolean/i)
  end

  it "allows nullable variable to non-null location with default value" do
    query_string = <<-QUERY
      query ($boolArg: Boolean = true) {
        arguments {
          nonNullBooleanArgField(nonNullBooleanArg: $boolArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects nullable variable to non-null location without default" do
    query_string = <<-QUERY
      query ($boolArg: Boolean) {
        arguments {
          nonNullBooleanArgField(nonNullBooleanArg: $boolArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/boolArg.*Boolean.*Boolean!/i)
  end

  it "allows non-null variable to nullable location" do
    query_string = <<-QUERY
      query ($intArg: Int!) {
        arguments {
          intArgField(intArg: $intArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows list variable to list location with matching item nullability" do
    query_string = <<-QUERY
      query ($listArg: [Boolean!]) {
        booleanList(booleanListArg: $listArg)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects non-list variable to list location" do
    query_string = <<-QUERY
      query ($boolArg: Boolean) {
        booleanList(booleanListArg: $boolArg)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/boolArg.*Boolean.*\[Boolean!\]/i)
  end

  it "allows [Boolean]! variable to [Boolean]! location" do
    query_string = <<-QUERY
      query ($listArg: [Boolean]!) {
        arguments {
          booleanListArgField(booleanListArg: $listArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows [Boolean!]! variable to [Boolean]! location (stricter item)" do
    query_string = <<-QUERY
      query ($listArg: [Boolean!]!) {
        arguments {
          booleanListArgField(booleanListArg: $listArg)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows variable usage in input object fields" do
    query_string = <<-QUERY
      query ($name: String) {
        findDog(searchBy: { name: $name }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects incompatible variable in input object field" do
    query_string = <<-QUERY
      query ($name: Int) {
        findDog(searchBy: { name: $name }) {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsagesAreAllowed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/name.*Int.*String/i)
  end
end
