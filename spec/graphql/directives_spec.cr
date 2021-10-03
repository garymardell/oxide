require "../spec_helper"

describe Graphql do
  it "does not have field if skip is true" do
    query_string = <<-QUERY
      query($toSkip: Boolean) {
        transactions {
          id
          reference @skip(if: $toSkip)
        }
      }
    QUERY

    variables = {
      "toSkip" => true.as(JSON::Any::Type)
    }

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string, variables)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "transactions" => [
        { "id" => "1" },
        { "id" => "32" }
      ]
    })
  end

  it "has field if skip is false" do
    query_string = <<-QUERY
      query($toSkip: Boolean) {
        transactions {
          id
          reference @skip(if: $toSkip)
        }
      }
    QUERY

    variables = {
      "toSkip" => false.as(JSON::Any::Type)
    }

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string, variables)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "transactions" => [
        { "id" => "1", "reference" => "ch_1234" },
        { "id" => "32", "reference" => "r_5678" }
      ]
    })
  end

  it "does not have field if include is false" do
    query_string = <<-QUERY
      query($toInclude: Boolean) {
        transactions {
          id
          reference @include(if: $toInclude)
        }
      }
    QUERY

    variables = {
      "toInclude" => false.as(JSON::Any::Type)
    }

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string, variables)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "transactions" => [
        { "id" => "1" },
        { "id" => "32" }
      ]
    })
  end

  it "has field if include is true" do
    query_string = <<-QUERY
      query($toInclude: Boolean) {
        transactions {
          id
          reference @include(if: $toInclude)
        }
      }
    QUERY

    variables = {
      "toInclude" => true.as(JSON::Any::Type)
    }

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string, variables)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "transactions" => [
        { "id" => "1", "reference" => "ch_1234" },
        { "id" => "32", "reference" => "r_5678" }
      ]
    })
  end
end