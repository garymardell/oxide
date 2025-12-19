require "../../spec_helper"

describe Oxide::Transport::SSEHandler do
  it "streams subscription events via SSE" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "tick" => Oxide::SubscriptionField.new(
            type: Oxide::Types::StringType.new,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              events = [{"value" => "1"}, {"value" => "2"}]
              Oxide::ArrayEventStream.new(events).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
              event["value"]
            }
          )
        }
      )
    )

    query = Oxide::Query.new("subscription { tick }")
    runtime = Oxide::Execution::Runtime.new(schema)
    stream = runtime.execute_subscription(query)

    response1 = stream.next
    response1.not_nil!.data.should eq({"tick" => "1"})

    response2 = stream.next
    response2.not_nil!.data.should eq({"tick" => "2"})

    response3 = stream.next
    response3.should be_nil
  end

  it "handles subscription with complex data types" do
    user_type = Oxide::Types::ObjectType.new(
      name: "User",
      fields: {
        "name" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { object["name"] }
        ),
        "email" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { object["email"] }
        )
      }
    )

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "userJoined" => Oxide::SubscriptionField.new(
            type: user_type,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              users = [
                {"name" => "Alice", "email" => "alice@example.com"}
              ]
              Oxide::ArrayEventStream.new(users).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(user : Hash(String, String), resolution : Oxide::Resolution) {
              user
            }
          )
        }
      )
    )

    query = Oxide::Query.new("subscription { userJoined { name email } }")
    runtime = Oxide::Execution::Runtime.new(schema)
    stream = runtime.execute_subscription(query)

    response = stream.next
    response.not_nil!.data.should eq({
      "userJoined" => {
        "name" => "Alice",
        "email" => "alice@example.com"
      }
    })
  end

  it "closes stream after all events are consumed" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "message" => Oxide::SubscriptionField.new(
            type: Oxide::Types::StringType.new,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              events = [{"msg" => "only one"}]
              Oxide::ArrayEventStream.new(events).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
              event["msg"]
            }
          )
        }
      )
    )

    query = Oxide::Query.new("subscription { message }")
    runtime = Oxide::Execution::Runtime.new(schema)
    stream = runtime.execute_subscription(query)

    # Get the only event
    response = stream.next
    response.not_nil!.data.should eq({"message" => "only one"})

    # Verify stream is done
    response2 = stream.next
    response2.should be_nil
  end
end
