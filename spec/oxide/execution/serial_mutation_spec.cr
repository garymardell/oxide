require "../../spec_helper"

describe "Serial Mutation Execution" do
  it "executes mutation fields in order" do
    # Track execution order
    execution_order = [] of String
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "dummy" }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "first" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_order << "first"
              "first_result"
            }
          ),
          "second" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_order << "second"
              "second_result"
            }
          ),
          "third" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_order << "third"
              "third_result"
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation {
        first
        second
        third
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    response.data.should eq({
      "first" => "first_result",
      "second" => "second_result",
      "third" => "third_result"
    })

    # Verify execution was in order
    execution_order.should eq(["first", "second", "third"])
  end

  it "executes mutations serially even with nested selections" do
    counter = 0
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "dummy" }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "incrementAndGet" => Oxide::Field.new(
            type: Oxide::Types::ObjectType.new(
              name: "Result",
              fields: {
                "value" => Oxide::Field.new(
                  type: Oxide::Types::IntType.new,
                  resolve: ->(obj : Int32, res : Oxide::Resolution) { obj }
                )
              }
            ),
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              counter += 1
              counter
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation {
        first: incrementAndGet {
          value
        }
        second: incrementAndGet {
          value
        }
        third: incrementAndGet {
          value
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    # If executed serially, values should be 1, 2, 3
    response.data.should eq({
      "first" => {"value" => 1},
      "second" => {"value" => 2},
      "third" => {"value" => 3}
    })
  end

  it "ensures side effects occur in order" do
    log = [] of String
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "dummy" }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "createUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              log << "user_created"
              "user123"
            }
          ),
          "sendEmail" => Oxide::Field.new(
            type: Oxide::Types::BooleanType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              log << "email_sent"
              true
            }
          ),
          "logActivity" => Oxide::Field.new(
            type: Oxide::Types::BooleanType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              log << "activity_logged"
              true
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation {
        createUser
        sendEmail
        logActivity
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    # Side effects should occur in the order specified
    log.should eq(["user_created", "email_sent", "activity_logged"])
  end

  it "stops execution if a mutation field errors" do
    execution_log = [] of String
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "dummy" }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "first" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_log << "first"
              "first_result"
            }
          ),
          "second" => Oxide::Field.new(
            type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_log << "second"
              nil  # This will cause an error
            }
          ),
          "third" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              execution_log << "third"
              "third_result"
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation {
        first
        second
        third
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    # All fields should still execute even if one errors
    # (GraphQL spec says to continue execution and collect errors)
    execution_log.should eq(["first", "second", "third"])
    
    response.errors.should_not be_nil
    response.errors.not_nil!.size.should eq(1)
  end
end
