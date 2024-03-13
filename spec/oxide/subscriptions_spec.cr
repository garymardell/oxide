require "../spec_helper"

describe Oxide do
  it "executes subscriptions" do
    query_string = <<-QUERY
      subscription {
        feed {
          id
        }
      }
    QUERY

    runtime = Oxide::Execution::Runtime.new(DummySchema)

    result = runtime.execute(query: Oxide::Query.new(query_string), initial_value: Query.new)

    pp result
  end
end