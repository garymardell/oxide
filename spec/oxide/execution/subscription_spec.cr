require "../../spec_helper"

describe "Subscription Execution" do
  it "executes a simple subscription" do
    # Define a message type
    message_type = Oxide::Types::ObjectType.new(
      name: "Message",
      fields: {
        "id" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) { message["id"] }
        ),
        "text" => Oxide::Field.new(
          type: Oxide::Types::StringType.new,
          resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) { message["text"] }
        )
      }
    )

    # Create a schema with a subscription field
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dummy" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "dummy" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::SubscriptionField.new(
            type: message_type,
            subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
              # Return a stream of message events
              messages = [
                {"id" => "1", "text" => "Hello"},
                {"id" => "2", "text" => "World"}
              ]
              Oxide::ArrayEventStream.new(messages)
            },
            resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
              message
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      subscription {
        newMessage {
          id
          text
        }
      }
    QUERY

    runtime = Oxide::Execution::Runtime.new(schema)
    query = Oxide::Query.new(query_string)
    
    stream = runtime.execute_subscription(query)
    
    # First event
    response1 = stream.next
    response1.should_not be_nil
    response1.not_nil!.data.should eq({"newMessage" => {"id" => "1", "text" => "Hello"}})
    response1.not_nil!.errors.should be_nil

    # Second event
    response2 = stream.next
    response2.should_not be_nil
    response2.not_nil!.data.should eq({"newMessage" => {"id" => "2", "text" => "World"}})

    # Stream should end
    stream.next.should be_nil
    
    stream.close
  end
end
