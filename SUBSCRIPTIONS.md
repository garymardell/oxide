# GraphQL Subscriptions in Oxide

Oxide provides full support for GraphQL subscriptions following the [GraphQL specification](https://spec.graphql.org/September2025/#sec-Subscription).

## Overview

Subscriptions allow clients to receive real-time updates from the server. Unlike queries and mutations which are request-response operations, subscriptions maintain a long-lived connection and push data to clients as events occur.

## Core Concepts

### Event Streams

Event streams are the foundation of subscriptions in Oxide. An event stream is an asynchronous source of events that can be iterated over time.

```crystal
# Abstract base class for all event streams
abstract class EventStream(T)
  abstract def next : T?
  abstract def close : Nil
end
```

Oxide provides three built-in event stream implementations:

1. **ArrayEventStream**: Simple stream backed by an array (useful for testing)
2. **ChannelEventStream**: Stream backed by a Crystal Channel (for concurrent event production)
3. **EmptyEventStream**: Stream that produces no events

### Subscription Fields

Subscription fields are special fields that have two functions:

1. **subscribe**: Creates and returns an event stream
2. **resolve**: Transforms each event into the final response value

```crystal
Oxide::SubscriptionField.new(
  type: SomeType,
  subscribe: ->(object : ParentType, resolution : Oxide::Resolution) {
    # Return an EventStream
    Oxide::ArrayEventStream.new([event1, event2, event3])
  },
  resolve: ->(event : EventType, resolution : Oxide::Resolution) {
    # Transform the event into the response
    event
  }
)
```

## Basic Example

Here's a simple subscription that sends a sequence of messages:

```crystal
# Define the Message type
message_type = Oxide::Types::ObjectType.new(
  name: "Message",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { 
        object["id"] 
      }
    ),
    "text" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : Hash(String, String), resolution : Oxide::Resolution) { 
        object["text"] 
      }
    )
  }
)

# Create schema with subscription
schema = Oxide::Schema.new(
  query: query_type,
  subscription: Oxide::Types::ObjectType.new(
    name: "Subscription",
    fields: {
      "newMessage" => Oxide::SubscriptionField.new(
        type: message_type,
        subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
          # In a real application, this would be a Channel or other event source
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

# Execute subscription
query = Oxide::Query.new("subscription { newMessage { id text } }")
runtime = Oxide::Execution::Runtime.new(schema)
stream = runtime.execute_subscription(query)

# Consume events
loop do
  response = stream.next
  break unless response
  
  puts response.data
  # => {"newMessage" => {"id" => "1", "text" => "Hello"}}
  # => {"newMessage" => {"id" => "2", "text" => "World"}}
end
```

## Using Channels for Real-Time Events

For real-world applications, you'll typically use Crystal Channels to produce events:

```crystal
# Create a channel for events
event_channel = Channel(Hash(String, String)).new

# Spawn a fiber to produce events
spawn do
  loop do
    sleep 1
    event_channel.send({"timestamp" => Time.utc.to_s})
  end
end

# Use the channel in a subscription
schema = Oxide::Schema.new(
  query: query_type,
  subscription: Oxide::Types::ObjectType.new(
    name: "Subscription",
    fields: {
      "tick" => Oxide::SubscriptionField.new(
        type: Oxide::Types::StringType.new,
        subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
          Oxide::ChannelEventStream.new(event_channel)
        },
        resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
          event["timestamp"]
        }
      )
    }
  )
)
```

## Transport Layers

Oxide provides two transport implementations for delivering subscription events to clients:

### WebSocket (graphql-ws protocol)

The recommended transport for subscriptions. Supports the [graphql-ws protocol](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md).

```crystal
require "http/server"
require "oxide"

schema = # ... your schema with subscriptions

server = HTTP::Server.new do |context|
  if context.request.path == "/graphql"
    # Handle WebSocket upgrade
    if context.request.headers["Upgrade"]? == "websocket"
      HTTP::WebSocket.new(context) do |socket|
        handler = Oxide::Transport::WebSocketHandler.new(socket, schema)
        handler.handle
      end
    end
  end
end

server.bind_tcp "0.0.0.0", 4000
server.listen
```

**Client Example** (JavaScript):

```javascript
import { createClient } from 'graphql-ws';

const client = createClient({
  url: 'ws://localhost:4000/graphql',
});

client.subscribe(
  {
    query: 'subscription { newMessage { id text } }',
  },
  {
    next: (data) => console.log(data),
    error: (error) => console.error(error),
    complete: () => console.log('Done'),
  }
);
```

### Server-Sent Events (SSE)

A simpler alternative using HTTP streaming. Good for server-to-client only communication.

```crystal
require "http/server"
require "oxide"

schema = # ... your schema with subscriptions

server = HTTP::Server.new do |context|
  if context.request.path == "/graphql/subscribe"
    # Parse query from request
    query = Oxide::Query.new(context.request.query_params["query"])
    
    # Handle as SSE
    Oxide::Transport::SSEHandler.handle(context, schema, query)
  end
end

server.bind_tcp "0.0.0.0", 4000
server.listen
```

**Client Example** (JavaScript):

```javascript
const eventSource = new EventSource(
  'http://localhost:4000/graphql/subscribe?query=subscription { newMessage { id text } }'
);

eventSource.addEventListener('next', (event) => {
  const data = JSON.parse(event.data);
  console.log(data);
});

eventSource.addEventListener('error', (event) => {
  console.error(event.data);
});
```

## Validation Rules

Subscriptions have special validation rules:

### Single Root Field

Subscription operations must select exactly one root field:

```graphql
# ✅ Valid - single root field
subscription {
  newMessage { text }
}

# ❌ Invalid - multiple root fields
subscription {
  newMessage { text }
  userJoined { name }
}
```

Introspection fields like `__typename` don't count as the root field:

```graphql
# ✅ Valid
subscription {
  __typename
  newMessage { text }
}
```

### Operation Type Existence

The schema must define a subscription type for subscription operations:

```crystal
# ✅ Valid - schema has subscription type
schema = Oxide::Schema.new(
  query: query_type,
  subscription: subscription_type  # Required for subscriptions
)

# ❌ Invalid - no subscription type
schema = Oxide::Schema.new(
  query: query_type
  # subscription operations will be rejected
)
```

## Advanced Patterns

### Filtering Events

You can use arguments to filter which events a client receives:

```crystal
Oxide::SubscriptionField.new(
  type: message_type,
  arguments: {
    "roomId" => Oxide::Argument.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    )
  },
  subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
    room_id = resolution.arguments["roomId"].as_s
    
    # Create a filtered event stream for this room
    channel = Channel(Hash(String, String)).new
    
    # Subscribe to global message bus and filter
    spawn do
      MESSAGE_BUS.subscribe do |message|
        if message["roomId"] == room_id
          channel.send(message)
        end
      end
    end
    
    Oxide::ChannelEventStream.new(channel)
  },
  resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
    message
  }
)
```

### Custom Event Streams

You can create custom event stream implementations:

```crystal
class DatabaseEventStream < Oxide::EventStream(Hash(String, String))
  def initialize(@connection : DB::Connection)
    @closed = false
  end
  
  def next : Hash(String, String)?
    return nil if @closed
    
    # Poll database for new events
    @connection.query_one?(
      "SELECT id, data FROM events WHERE processed = false LIMIT 1",
      as: {String, String}
    ).try do |id, data|
      {"id" => id, "data" => data}
    end
  end
  
  def close : Nil
    @closed = true
  end
end
```

### Authentication & Authorization

Add authentication to your subscription handlers:

```crystal
# WebSocket with authentication
HTTP::WebSocket.new(context) do |socket|
  # Extract token from connection_init payload
  authenticated = false
  user = nil
  
  socket.on_message do |message|
    data = JSON.parse(message)
    
    if data["type"] == "connection_init"
      token = data["payload"]?.try(&.["token"]?)
      user = authenticate(token)
      authenticated = !user.nil?
      
      if authenticated
        socket.send({type: "connection_ack"}.to_json)
      else
        socket.send({type: "connection_error", payload: "Unauthorized"}.to_json)
        socket.close
      end
    elsif authenticated
      # Handle other messages
      handler = Oxide::Transport::WebSocketHandler.new(socket, schema)
      handler.handle
    end
  end
end
```

## Error Handling

Errors during subscription execution are sent to clients:

```crystal
Oxide::SubscriptionField.new(
  type: message_type,
  subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
    # If subscribe raises an error, it's sent to the client
    raise "Not authorized" unless authorized?
    
    Oxide::ArrayEventStream.new(events)
  },
  resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
    # Errors in resolve are sent for that specific event
    raise "Invalid event" unless valid?(event)
    
    event
  }
)
```

## Performance Considerations

### Memory Management

- Close event streams when clients disconnect to free resources
- Use channels with bounded capacity to prevent memory buildup
- Consider implementing backpressure for slow clients

### Scaling

- Use a message bus (Redis, NATS, etc.) for multi-server deployments
- Consider limiting concurrent subscriptions per client
- Implement connection limits and rate limiting

### Example with Redis Pub/Sub

```crystal
require "redis"

redis = Redis.new

Oxide::SubscriptionField.new(
  type: message_type,
  subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
    channel = Channel(Hash(String, String)).new
    
    spawn do
      redis.subscribe("messages") do |on|
        on.message do |channel_name, message|
          data = JSON.parse(message)
          channel.send(data.as_h.transform_values(&.to_s))
        end
      end
    end
    
    Oxide::ChannelEventStream.new(channel)
  },
  resolve: ->(message : Hash(String, String), resolution : Oxide::Resolution) {
    message
  }
)
```

## Testing

Testing subscriptions is straightforward with ArrayEventStream:

```crystal
it "sends multiple events" do
  schema = create_schema_with_subscription
  
  query = Oxide::Query.new("subscription { newMessage { text } }")
  runtime = Oxide::Execution::Runtime.new(schema)
  stream = runtime.execute_subscription(query)
  
  # Verify first event
  response1 = stream.next
  response1.not_nil!.data.should eq({"newMessage" => {"text" => "Hello"}})
  
  # Verify second event
  response2 = stream.next
  response2.not_nil!.data.should eq({"newMessage" => {"text" => "World"}})
  
  # Verify stream ends
  response3 = stream.next
  response3.should be_nil
end
```

## API Reference

### EventStream(T)

Abstract base class for event streams.

**Methods:**
- `next : T?` - Returns the next event, or nil if the stream is complete
- `close : Nil` - Closes the stream and releases resources

### ArrayEventStream(T)

Simple event stream backed by an array.

```crystal
events = [1, 2, 3]
stream = Oxide::ArrayEventStream.new(events)
```

### ChannelEventStream(T)

Event stream backed by a Crystal Channel.

```crystal
channel = Channel(String).new
stream = Oxide::ChannelEventStream.new(channel)

spawn do
  channel.send("event1")
  channel.send("event2")
  channel.close
end
```

### SubscriptionField(I, E, O)

Special field type for subscriptions.

**Type Parameters:**
- `I` - Input object type (parent object)
- `E` - Event type produced by the subscribe function
- `O` - Output type returned by the resolve function

**Constructor:**
```crystal
Oxide::SubscriptionField.new(
  type: Oxide::Type,
  subscribe: Proc(I, Resolution, EventStream(E)),
  resolve: Proc(E, Resolution, O),
  arguments: Hash(String, Argument) = {},
  description: String? = nil
)
```

### Runtime#execute_subscription

Executes a subscription operation.

```crystal
runtime = Oxide::Execution::Runtime.new(schema)
stream = runtime.execute_subscription(query, context)
```

**Returns:** `EventStream(Response)` - Stream of GraphQL responses

### WebSocketHandler

Handles GraphQL subscriptions over WebSocket using the graphql-ws protocol.

```crystal
handler = Oxide::Transport::WebSocketHandler.new(socket, schema, context)
handler.handle
```

### SSEHandler

Handles GraphQL subscriptions over Server-Sent Events.

```crystal
Oxide::Transport::SSEHandler.handle(http_context, schema, query, context)
```

## Migration Guide

If you're adding subscriptions to an existing Oxide schema:

1. **Add a subscription root type to your schema:**
```crystal
schema = Oxide::Schema.new(
  query: query_type,
  mutation: mutation_type,
  subscription: subscription_type  # Add this
)
```

2. **Create subscription fields using SubscriptionField:**
```crystal
subscription_type = Oxide::Types::ObjectType.new(
  name: "Subscription",
  fields: {
    "myEvent" => Oxide::SubscriptionField.new(
      type: event_type,
      subscribe: ->(obj : Nil, res : Oxide::Resolution) { 
        # Return an EventStream
      },
      resolve: ->(event : EventType, res : Oxide::Resolution) { 
        # Transform event to response
      }
    )
  }
)
```

3. **Choose a transport layer (WebSocket or SSE)**

4. **Update your client to use subscription protocol**

## Troubleshooting

### "Subscription must have only one root field"

This error occurs when a subscription operation selects multiple root fields. Subscriptions can only select one field at the root level.

**Solution:** Split into multiple subscription operations or redesign your schema.

### "Schema does not define a subscription type"

The schema doesn't have a subscription root type defined.

**Solution:** Add `subscription: subscription_type` when creating your schema.

### Events not being sent to clients

Common causes:
- Event stream not producing events (check your subscribe function)
- Client disconnected (check connection status)
- Errors in resolve function (check logs)

**Solution:** Add logging to your subscribe and resolve functions to debug.

### Memory leaks with long-running subscriptions

**Solution:** 
- Ensure streams are properly closed when clients disconnect
- Use bounded channels
- Implement cleanup logic in your event producers

## Further Reading

- [GraphQL Specification - Subscriptions](https://spec.graphql.org/September2025/#sec-Subscription)
- [graphql-ws Protocol](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md)
- [Server-Sent Events Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html)
