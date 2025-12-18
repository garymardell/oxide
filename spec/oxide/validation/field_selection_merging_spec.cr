require "../../spec_helper"

describe Oxide::Validation::FieldSelectionMerging do
  it "allows fields with same name and type" do
    query_string = <<-QUERY
      {
        dog {
          name
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelectionMerging.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows fields with different aliases" do
    query_string = <<-QUERY
      {
        dog {
          name1: name
          name2: name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelectionMerging.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects same alias for different fields" do
    query_string = <<-QUERY
      {
        dog {
          fido: name
          fido: nickname
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelectionMerging.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/fido.*conflict/i)
  end

  it "allows merging fields from inline fragments with same type" do
    query_string = <<-QUERY
      {
        dog {
          name
          ... on Dog {
            name
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelectionMerging.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows fields with compatible return types" do
    query_string = <<-QUERY
      {
        dog {
          owner {
            name
          }
          owner {
            name
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FieldSelectionMerging.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end
