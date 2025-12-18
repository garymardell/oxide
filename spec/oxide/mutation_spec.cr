require "../spec_helper"

describe Oxide do
  it "executes mutation" do
    query_string = <<-QUERY
      mutation CreateCharge {
        createCharge(input: { reference: "test" }) {
          id
        }
      }
    QUERY

    runtime = Oxide::Execution::Runtime.new(DummySchema)

    result = runtime.execute(query: Oxide::Query.new(query_string), initial_value: Query.new).data

    result.should eq({ "createCharge" => { "id" => "1" } })
  end

  it "executes mutation with empty fields" do
    query_string = <<-QUERY
      mutation CreateCharge {
        createCharge(input: { reference: "" }) {
          id
          reference
        }
      }
    QUERY

    runtime = Oxide::Execution::Runtime.new(DummySchema)

    result = runtime.execute(query: Oxide::Query.new(query_string), initial_value: Query.new).data

    result.should eq({ "createCharge" => { "id" => "1", "reference" => "" } })
  end
end