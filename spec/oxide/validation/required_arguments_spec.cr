require "../../spec_helper"

describe Oxide::Validation::RequiredArguments do
  it "example #142 - good boolean arg" do
    query_string = <<-QUERY
      fragment goodBooleanArg on Arguments {
        booleanArgField(booleanArg: true)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "example #142 - good non-null arg" do
    query_string = <<-QUERY
      fragment goodNonNullArg on Arguments {
        nonNullBooleanArgField(nonNullBooleanArg: true)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "example #143 - good boolean arg with default (omitted)" do
    query_string = <<-QUERY
      fragment goodBooleanArgDefault on Arguments {
        booleanArgField
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #144 - missing required arg" do
    query_string = <<-QUERY
      fragment missingRequiredArg on Arguments {
        nonNullBooleanArgField
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.not_nil!.should contain("nonNullBooleanArg")
    runtime.errors.first.message.not_nil!.should contain("required")
  end

  it "counter example #145 - null value for required arg" do
    query_string = <<-QUERY
      fragment missingRequiredArg on Arguments {
        nonNullBooleanArgField(nonNullBooleanArg: null)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.not_nil!.should contain("nonNullBooleanArg")
    runtime.errors.first.message.not_nil!.should contain("cannot be null")
  end

  it "required argument on directive" do
    query_string = <<-QUERY
      query {
        dog {
          name @include
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.not_nil!.should contain("@include")
    runtime.errors.first.message.not_nil!.should contain("if")
    runtime.errors.first.message.not_nil!.should contain("required")
  end

  it "required argument on directive with null" do
    query_string = <<-QUERY
      query {
        dog {
          name @include(if: null)
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.not_nil!.should contain("@include")
    runtime.errors.first.message.not_nil!.should contain("if")
    runtime.errors.first.message.not_nil!.should contain("cannot be null")
  end

  it "multiple missing required arguments" do
    query_string = <<-QUERY
      fragment multipleRequirements on Arguments {
        multipleRequirements
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
  end

  it "all required arguments provided" do
    query_string = <<-QUERY
      fragment multipleRequirements on Arguments {
        multipleRequirements(x: 1, y: 2)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::RequiredArguments.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end
end