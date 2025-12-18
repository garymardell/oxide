require "../../spec_helper"

describe Oxide::Validation::FragmentSpreadTypeExistence do
  describe "example #148" do
    it "accepts fragments on existing types" do
      query_string = <<-QUERY
        fragment correctType on Dog {
          name
        }

        fragment inlineFragment on Dog {
          ... on Dog {
            name
          }
        }

        fragment inlineFragment2 on Dog {
          ... @include(if: true) {
            name
          }
        }

        {
          dog {
            ...correctType
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "counter example #149" do
    it "rejects fragments on non-existent types" do
      query_string = <<-QUERY
        fragment notOnExistingType on NotInSchema {
          name
        }

        fragment inlineNotExistingType on Dog {
          ... on NotInSchema {
            name
          }
        }

        {
          dog {
            ...notOnExistingType
            ...inlineNotExistingType
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 2
      
      # Check for error about notOnExistingType fragment
      has_fragment_error = runtime.errors.any? do |error|
        msg = error.message
        msg && (msg.includes?("NotInSchema") || msg.includes?("notOnExistingType"))
      end
      has_fragment_error.should be_true
      
      # Check for error about inline fragment
      has_inline_error = runtime.errors.any? do |error|
        msg = error.message
        msg && msg.includes?("NotInSchema")
      end
      has_inline_error.should be_true
    end
  end

  it "accepts fragments on interfaces" do
    query_string = <<-QUERY
      fragment onInterface on Pet {
        name
      }

      {
        dog {
          ...onInterface
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts fragments on unions" do
    query_string = <<-QUERY
      fragment onUnion on CatOrDog {
        ... on Dog {
          name
        }
      }

      {
        dog {
          ...onUnion
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts inline fragments on existing types" do
    query_string = <<-QUERY
      {
        dog {
          ... on Dog {
            name
          }
          ... on Pet {
            name
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects inline fragments on non-existent types" do
    query_string = <<-QUERY
      {
        dog {
          ... on NonExistentType {
            someField
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    msg = runtime.errors.first.message
    msg.should_not be_nil
    msg.should match(/NonExistentType/) if msg
  end

  it "accepts inline fragments without type condition" do
    query_string = <<-QUERY
      {
        dog {
          ... {
            name
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end