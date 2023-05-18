require "../../spec_helper"

describe Graphene::Execution::Runtime do
  it "handles fragments on Interface" do
    query_string = <<-QUERY
      query {
        transactions {
          ...TransactionInfo
        }
      }

      fragment TransactionInfo on Transaction {
        id
        reference
      }
    QUERY

    runtime = Graphene::Execution::Runtime.new(
      DummySchema,
      Graphene::Query.new(query_string)
    )

    result = runtime.execute(initial_value: Query.new)

    expected_transactions = [
      { "id" => "1", "reference" => "ch_1234" },
      { "id" => "32", "reference" => "r_5678" },
    ]

    result["errors"]?.should be_nil
    result["data"].should eq({ "transactions" => expected_transactions })
  end
end