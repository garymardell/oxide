require "../spec_helper"

class Message
  property body : String

  def initialize(@body)
  end
end

class MessageWasPostedEvent
  property message : Message

  def initialize(@message)
  end
end

class Subscription
  @@subscriptions = Hash(String, Subscription).new

  def self.subscribe(key, &blk : String? ->)
    @@subscriptions[key] ||= Subscription.new(blk)
    @@subscriptions[key].stream
  end

  def self.trigger(key, data)
    subscription = @@subscriptions[key]
    subscription.update(data)
  end

  getter stream : Graphql::Stream(MessageWasPostedEvent)

  def initialize(blk : String? ->)
    @stream = Graphql::Stream(MessageWasPostedEvent).new(&blk)
  end

  def update(payload)
    stream.emit(payload)
  end
end


class Client
  property transmitted : Array(String | Nil)

  def initialize
    @transmitted = [] of String | Nil
  end

  def transmit(data)
    transmitted << data
  end
end

class SubscriptionContext < Graphql::Context
  property client : Client

  def initialize(@client)
  end
end

class SubscriptionManager < Graphql::Schema::Subscriber
  def subscribe(object, context : SubscriptionContext, field_name, argument_values)
    case field_name
    when "messageWasPosted"
      Subscription.subscribe("messages") do |response|
        context.client.transmit(response)
      end
    end
  end
end

class SubscriptionResolver < Graphql::Schema::Resolver
  def resolve(object, context : SubscriptionContext, field_name, argument_values)
    object
  end
end

class MessageWasPostedResolver < Graphql::Schema::Resolver
  def resolve(object : MessageWasPostedEvent, context, field_name, argument_values)
    case field_name
    when "message"
      object.message
    end
  end
end

class MessageResolver < Graphql::Schema::Resolver
  def resolve(object : Message, context, field_name, argument_values)
    case field_name
    when "body"
      object.body
    end
  end
end

describe Graphql do
  it "supports subscriptions" do
    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new,
      ),
      subscription: Graphql::Type::Subscription.new(
        typename: "Subscription",
        subscriber: SubscriptionManager.new,
        resolver: SubscriptionResolver.new,
        fields: [
          Graphql::Schema::Field.new(
            name: "messageWasPosted",
            type: Graphql::Type::Object.new(
              typename: "MessageWasPosted",
              resolver: MessageWasPostedResolver.new,
              fields: [
                Graphql::Schema::Field.new(
                  name: "message",
                  type: Graphql::Type::Object.new(
                    typename: "Message",
                    resolver: MessageResolver.new,
                    fields: [
                      Graphql::Schema::Field.new(
                        name: "body",
                        type: Graphql::Type::String.new
                      )
                    ]
                  )
                )
              ]
            ),
            arguments: [
              Graphql::Schema::Argument.new(
                name: "roomId",
                type: Graphql::Type::Id.new
              )
            ]
          )
        ]
      )
    )

    query_string = <<-QUERY
      subscription {
        messageWasPosted(roomId: "abcd") {
          message {
            body
          }
        }
      }
    QUERY

    # Connection between client and server
    client = Client.new
    context = SubscriptionContext.new(client)

    # Subscription for client has been established on key "messages"
    query = Graphql::Query.new(query_string, context)

    runtime = Graphql::Execution::Runtime.new(
      schema: schema,
      query: query
    )

    runtime.execute

    # Another process triggers an update
    Subscription.trigger("messages", MessageWasPostedEvent.new(Message.new(body: "first")))
    Subscription.trigger("messages", MessageWasPostedEvent.new(Message.new(body: "second")))

    expected = [
      "{\"messageWasPosted\":{\"message\":{\"body\":\"first\"}}}",
      "{\"messageWasPosted\":{\"message\":{\"body\":\"second\"}}}"
    ]

    client.transmitted.should eq(expected)
  end
end