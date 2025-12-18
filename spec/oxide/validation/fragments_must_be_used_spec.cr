require "../../spec_helper"

describe Oxide::Validation::FragmentsMustBeUsed do
  describe "counter example #153" do
    it "reports error when fragment is defined but never used" do
      query_string = <<-QUERY
        fragment nameFragment on Dog {
          name
        }

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
        [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should eq(1)
      runtime.errors.first.message.should match(/nameFragment.*never used|never used.*nameFragment/i)
    end
  end

  it "accepts queries where all fragments are used" do
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
      [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "reports multiple unused fragments" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      fragment barkFragment on Dog {
        barkVolume
      }

      fragment ownerFragment on Dog {
        owner {
          name
        }
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
      [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(2)
    error_messages = runtime.errors.map(&.message).join(" ")
    error_messages.should match(/barkFragment/i)
    error_messages.should match(/ownerFragment/i)
  end

  it "accepts fragments used in other fragments" do
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
      [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts fragments used in inline fragments" do
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
      [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
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
      [Oxide::Validation::FragmentsMustBeUsed.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end
