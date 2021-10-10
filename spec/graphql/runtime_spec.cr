require "../spec_helper"

describe Graphql do
  it "executes" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }, { "id" => "3" }] })
  end

  it "executes with errors" do
    query_string = <<-QUERY
      query {
        charges {
          id
          status
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)

    expected_errors = [
      {
        "message" => "Cannot return null for non-nullable field Charge.status"
      }
    ]

    # expected_data = nil

    expected_data = {
      "charges" => [
        nil,
        { "id" => "2", "status" => "PENDING" },
        nil
      ]
    }

    result["data"].should eq(expected_data)
    result["errors"].should eq(expected_errors)
  end

  it "executes with loader" do
    query_string = <<-QUERY
      query {
        charges {
          id
          refund {
            status

            payment_method {
              ... on BankAccount {
                accountNumber
              }
            }
          }
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    expected_response = {
      "charges" => [
        { "id" => "1", "refund" => { "status" => "PENDING", "payment_method" => { "accountNumber" => "1234578" } } },
        { "id" => "2", "refund" => { "status" => "PENDING", "payment_method" => { "accountNumber" => "1234578" } } },
        { "id" => "3", "refund" => { "status" => "PENDING", "payment_method" => { "accountNumber" => "1234578" } } }
      ]
    }

    result.should eq(expected_response)
  end

  it "supports interfaces" do
    query_string = <<-QUERY
      query {
        transactions {
          id
          reference

          ... on Refund {
            partial
          }
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "transactions" => [
        { "id" => "1", "reference" => "ch_1234" },
        { "id" => "32", "reference" => "r_5678", "partial" => true }
      ]
    })
  end

  it "supports unions" do
    query_string = <<-QUERY
      query {
        paymentMethods {
          id

          ... on CreditCard {
            last4
          }

          ... on BankAccount {
            accountNumber
          }
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({
      "paymentMethods" => [
        { "id" => "1", "last4" => "4242" },
        { "id" => "32", "accountNumber" => "1234567" }
      ]
    })
  end

  it "supports fragment spread and variables", focus: false do
    query_string = <<-QUERY
      fragment ChargeInfo on Charge {
        id
      }

      query($id: ID! = 1) {
        charge(id: $id) {
          ...ChargeInfo
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charge" => { "id" => "1" } })
  end

  it "supports arguments", focus: false do
    query_string = <<-QUERY
      query($id: ID!) {
        charge(id: $id) {
          id
        }
      }
    QUERY

    variables = JSON.parse <<-STRING
      {
        "id": "10"
      }
    STRING

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(
        query_string,
        variables: variables.as_h
      )
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charge" => { "id" => "10" } })
  end

  it "supports arguments with default values", focus: false do
    query_string = <<-QUERY
      query($id: ID! = 1) {
        charge(id: $id) {
          id
        }
      }
    QUERY

    variables = {} of String => JSON::Any

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(
        query_string,
        variables: variables
      )
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charge" => { "id" => "1" } })
  end

  it "supports dynamically generated schema" do
    fields = [
      "foo",
      "bar"
    ]

    query_type = Graphql::Type::Object.new(
      typename: "DynamicQuery",
      resolver: DynamicResolver.new,
      fields: fields.map do |field_name|
        Graphql::Schema::Field.new(
          name: field_name,
          type: Graphql::Type::String.new
        )
      end
    )

    schema = Graphql::Schema.new(query: query_type)

    query_string = <<-QUERY
      query {
        foo
        bar
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      schema,
      Graphql::Query.new(query_string)
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "foo" => "foo", "bar" => "bar" })
  end

  it "executes correct operation definition" do
    query_string = <<-QUERY
      query allPaymentMethods {
        paymentMethods {
          id
        }
      }

      query allCharges {
        charges {
          id
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema.compile,
      Graphql::Query.new(query_string, operation_name: "allCharges")
    )

    result = JSON.parse(runtime.execute)["data"]

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }, { "id" => "3" }] })
  end
end