require "../src/oxide"
require "http/server"

# This example demonstrates a simple chat application using GraphQL subscriptions

# Define the Message type
message_type = Oxide::Types::ObjectType.new(
  name: "Message",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
      resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) {
        object["id"]
      }
    ),
    "text" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
      resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) {
        object["text"]
      }
    ),
    "author" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
      resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) {
        object["author"]
      }
    )
  }
)

# Message broadcaster for pub/sub pattern
class MessageBroadcaster
  @subscribers = [] of Channel(Hash(String, String))
  @mutex = Mutex.new

  def subscribe : Channel(Hash(String, String))
    channel = Channel(Hash(String, String)).new(100)
    @mutex.synchronize do
      @subscribers << channel
    end
    channel
  end

  def unsubscribe(channel : Channel(Hash(String, String)))
    @mutex.synchronize do
      @subscribers.delete(channel)
    end
    channel.close
  end

  def broadcast(message : Hash(String, String))
    @mutex.synchronize do
      @subscribers.each do |subscriber|
        spawn { subscriber.send(message) }
      end
    end
  end
end

MESSAGE_BROADCASTER = MessageBroadcaster.new
MESSAGE_ID = Atomic(Int32).new(0)

# Query type (required by GraphQL spec)
query_type = Oxide::Types::ObjectType.new(
  name: "Query",
  fields: {
    "hello" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : Nil, resolution : Oxide::Resolution) {
        "Welcome to the chat!"
      }
    )
  }
)

# Mutation type for sending messages
mutation_type = Oxide::Types::ObjectType.new(
  name: "Mutation",
  fields: {
    "sendMessage" => Oxide::Field.new(
      arguments: {
        "text" => Oxide::Argument.new(
          type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new)
        ),
        "author" => Oxide::Argument.new(
          type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new)
        )
      },
      type: message_type,
      resolve: ->(object : Nil, resolution : Oxide::Resolution) {
        text = resolution.arguments["text"].as_s
        author = resolution.arguments["author"].as_s
        id = MESSAGE_ID.add(1).to_s

        message = {
          "id" => id,
          "text" => text,
          "author" => author
        }

        # Broadcast to all subscribers
        MESSAGE_BROADCASTER.broadcast(message)

        message
      }
    )
  }
)

# Subscription type
subscription_type = Oxide::Types::ObjectType.new(
  name: "Subscription",
  fields: {
    "messageAdded" => Oxide::SubscriptionField.new(
      type: message_type,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        # Subscribe to the broadcaster
        subscriber_channel = MESSAGE_BROADCASTER.subscribe
        Oxide::ChannelEventStream.new(subscriber_channel).as(Oxide::EventStream(Hash(String, String)))
      },
      resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
        message
      }
    )
  }
)

# Create the schema
schema = Oxide::Schema.new(
  query: query_type,
  mutation: mutation_type,
  subscription: subscription_type
)

puts "🚀 GraphQL Chat Server starting..."
puts "   WebSocket endpoint: ws://localhost:4321/graphql"
puts "   Use a GraphQL client to connect and subscribe to messageAdded"
puts ""
puts "Example subscription:"
puts "  subscription { messageAdded { id text author } }"
puts ""
puts "Example mutation:"
puts "  mutation { sendMessage(text: \"Hello!\", author: \"Alice\") { id text author } }"
puts ""

# WebSocket handler for subscriptions
ws_handler = HTTP::WebSocketHandler.new do |socket|
  puts "📡 New WebSocket connection"

  handler = Oxide::Transport::WebSocketHandler.new(socket, schema)

  begin
    handler.handle
  ensure
    puts "❌ WebSocket connection closed"
  end
end

# CORS handler to allow browser access
class CORSHandler
  include HTTP::Handler

  def call(context)
    # Set CORS headers
    context.response.headers["Access-Control-Allow-Origin"] = "*"
    context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    context.response.headers["Access-Control-Allow-Headers"] = "Content-Type"

    # Handle preflight OPTIONS request
    if context.request.method == "OPTIONS"
      context.response.status = HTTP::Status::OK
      return
    end

    call_next(context)
  end
end

# HTTP handler for queries/mutations
class GraphQLHandler
  include HTTP::Handler

  def initialize(@schema : Oxide::Schema)
  end

  def call(context)
    if context.request.path == "/graphql" && context.request.method == "POST"
      body = context.request.body.try(&.gets_to_end)

      if body
        data = JSON.parse(body)
        query_string = data["query"].as_s
        variables = data["variables"]?.try(&.as_h) || {} of String => JSON::Any

        query = Oxide::Query.new(query_string, variables: variables)
        runtime = Oxide::Execution::Runtime.new(@schema)

        # Execute query or mutation
        response = runtime.execute(query)

        context.response.content_type = "application/json"
        context.response.print(response.to_json)
      else
        context.response.status = HTTP::Status::BAD_REQUEST
        context.response.print("Missing query")
      end
    else
      call_next(context)
    end
  end
end

cors_handler = CORSHandler.new
http_handler = GraphQLHandler.new(schema)

server = HTTP::Server.new([cors_handler, ws_handler, http_handler])
address = server.bind_tcp "0.0.0.0", 4321
puts "✅ Listening on http://#{address}"
server.listen
