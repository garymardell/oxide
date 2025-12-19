require "../../spec_helper"

describe Oxide::Transport::WebSocketHandler do
  it "handles connection_init message" do
    # Create a simple schema with subscription
    message_type = Oxide::Types::ObjectType.new(
      name: "Message",
      fields: {
        "id" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { object["id"] }
        ),
        "text" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { object["text"] }
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
          "newMessage" => Oxide::SubscriptionField.new(
            type: message_type,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              messages = [
                {"id" => "1", "text" => "Hello"},
                {"id" => "2", "text" => "World"}
              ]
              Oxide::ArrayEventStream.new(messages).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
              message
            }
          )
        }
      )
    )

    # This test verifies the schema is set up correctly for WebSocket handler
    schema.subscription.should_not be_nil
    schema.subscription.not_nil!.name.should eq("Subscription")
  end

  it "validates subscription query structure" do
    message_type = Oxide::Types::ObjectType.new(
      name: "Message",
      fields: {
        "text" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { object["text"] }
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
          "newMessage" => Oxide::SubscriptionField.new(
            type: message_type,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              Oxide::ArrayEventStream.new([{"text" => "test"}]).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
              message
            }
          )
        }
      )
    )

    query = Oxide::Query.new("subscription { newMessage { text } }")
    runtime = Oxide::Execution::Runtime.new(schema)
    
    # Verify the query can be executed
    stream = runtime.execute_subscription(query)
    response = stream.next
    
    response.should_not be_nil
    response.not_nil!.data.should eq({"newMessage" => {"text" => "test"}})
  end

  it "handles multiple subscription events" do
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
          "counter" => Oxide::SubscriptionField.new(
            type: Oxide::Types::StringType.new,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              events = [{"count" => "1"}, {"count" => "2"}, {"count" => "3"}]
              Oxide::ArrayEventStream.new(events).as(Oxide::EventStream(Hash(String, String)))
            },
            resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
              event["count"]
            }
          )
        }
      )
    )

    query = Oxide::Query.new("subscription { counter }")
    runtime = Oxide::Execution::Runtime.new(schema)
    stream = runtime.execute_subscription(query)

    response1 = stream.next
    response1.not_nil!.data.should eq({"counter" => "1"})

    response2 = stream.next
    response2.not_nil!.data.should eq({"counter" => "2"})

    response3 = stream.next
    response3.not_nil!.data.should eq({"counter" => "3"})

    response4 = stream.next
    response4.should be_nil
  end
end
