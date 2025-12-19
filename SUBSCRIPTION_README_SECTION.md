# GraphQL Subscriptions Support

Add this section to the main README.md to document subscription support.

---

## Subscriptions

Oxide fully supports GraphQL subscriptions for real-time data streaming. Subscriptions allow clients to receive updates when events occur on the server.

### Quick Example

```crystal
require "oxide"

# Define your subscription type
subscription_type = Oxide::Types::ObjectType.new(
  name: "Subscription",
  fields: {
    "messageAdded" => Oxide::SubscriptionField.new(
      type: message_type,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        # Return an event stream
        Oxide::ChannelEventStream.new(message_channel)
      },
      resolve: ->(message : Message, resolution : Oxide::Resolution) {
        # Transform event to response
        message
      }
    )
  }
)

# Create schema with subscription support
schema = Oxide::Schema.new(
  query: query_type,
  mutation: mutation_type,
  subscription: subscription_type
)

# Execute a subscription
query = Oxide::Query.new("subscription { messageAdded { id text } }")
runtime = Oxide::Execution::Runtime.new(schema)
stream = runtime.execute_subscription(query)

# Consume events
loop do
  response = stream.next
  break unless response
  puts response.data
end
```

### Transport Options

Oxide provides two transport implementations:

#### WebSocket (Recommended)

Uses the [graphql-ws protocol](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md):

```crystal
require "http/server"
require "oxide"

server = HTTP::Server.new do |context|
  if context.request.headers["Upgrade"]? == "websocket"
    HTTP::WebSocket.new(context) do |socket|
      handler = Oxide::Transport::WebSocketHandler.new(socket, schema)
      handler.handle
    end
  end
end

server.bind_tcp "0.0.0.0", 4000
server.listen
```

#### Server-Sent Events (SSE)

Simpler alternative for server-to-client streaming:

```crystal
Oxide::Transport::SSEHandler.handle(http_context, schema, query)
```

### Event Streams

Oxide provides flexible event stream implementations:

- **ArrayEventStream** - For testing and simple use cases
- **ChannelEventStream** - For concurrent event production
- **EmptyEventStream** - For no-event scenarios
- **Custom streams** - Implement `EventStream(T)` interface

### Features

- ✅ Full GraphQL subscription spec compliance
- ✅ WebSocket transport (graphql-ws protocol)
- ✅ Server-Sent Events transport
- ✅ Subscription validation rules
- ✅ Type-safe event streams
- ✅ Channel-based concurrency
- ✅ Custom event stream support

### Documentation

See [SUBSCRIPTIONS.md](SUBSCRIPTIONS.md) for comprehensive documentation including:
- Detailed API reference
- Advanced patterns
- Authentication & authorization
- Error handling
- Performance considerations
- Testing strategies
- Migration guide

### Example Application

Check out [examples/subscription_example.cr](examples/subscription_example.cr) for a complete chat application using subscriptions.

---
