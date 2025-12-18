require "../../spec_helper"

describe Oxide::Validation::FragmentSpreadTargetDefined do
  describe "counter example #154" do
    it "reports error when fragment spread refers to undefined fragment" do
      query_string = <<-QUERY
        {
          dog {
            ...undefinedFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should eq(1)
      runtime.errors.first.message.should match(/undefinedFragment.*not defined|not defined.*undefinedFragment/i)
    end
  end

  it "accepts queries where all fragment spreads are defined" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      {
        dog {
          ...nameFragment
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "reports multiple undefined fragments" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      {
        dog {
          ...nameFragment
          ...undefinedFragment1
          ...undefinedFragment2
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
    error_messages = runtime.errors.map(&.message).join(" ")
    error_messages.should match(/undefinedFragment1/i)
    error_messages.should match(/undefinedFragment2/i)
  end

  it "accepts nested fragment spreads when all are defined" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      fragment dogFragment on Dog {
        ...nameFragment
        barkVolume
      }

      {
        dog {
          ...dogFragment
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "reports error for undefined fragment in nested fragment" do
    query_string = <<-QUERY
      fragment dogFragment on Dog {
        ...undefinedNestedFragment
        barkVolume
      }

      {
        dog {
          ...dogFragment
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/undefinedNestedFragment/i)
  end

  it "accepts queries with no fragments" do
    query_string = <<-QUERY
      {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts fragment spreads in inline fragments" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      {
        dog {
          ... on Dog {
            ...nameFragment
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTargetDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end
