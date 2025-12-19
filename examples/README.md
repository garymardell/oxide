# GraphQL Subscription Chat Example

This example demonstrates a real-time chat application using GraphQL subscriptions with Oxide.

## Features

- ✅ Real-time message broadcasting using GraphQL subscriptions
- ✅ WebSocket transport (graphql-ws protocol)
- ✅ HTTP mutations for sending messages
- ✅ Beautiful web-based chat interface
- ✅ Automatic reconnection
- ✅ Channel-based event streaming

## Running the Example

### 1. Start the Server

```bash
crystal run examples/subscription_example.cr
```

You should see:
```
🚀 GraphQL Chat Server starting...
   WebSocket endpoint: ws://localhost:4000/graphql
   Use a GraphQL client to connect and subscribe to messageAdded

Example subscription:
  subscription { messageAdded { id text author } }

Example mutation:
  mutation { sendMessage(text: "Hello!", author: "Alice") { id text author } }

✅ Listening on http://0.0.0.0:4000
```

### 2. Open the Web Client

Simply open `examples/chat_client.html` in your web browser:

```bash
# On macOS
open examples/chat_client.html

# On Linux
xdg-open examples/chat_client.html

# Or just drag the file into your browser
```

### 3. Start Chatting!

1. Enter your name in the first input field
2. Type a message in the second input field
3. Click "Send" or press Enter
4. Open the page in multiple browser tabs to see real-time updates!

## How It Works

### Backend (Crystal)

The server implements:
- **Subscription Root Type**: Defines `messageAdded` subscription field
- **Mutation Root Type**: Defines `sendMessage` mutation
- **Event Broadcasting**: Uses Crystal Channel to broadcast messages to all subscribers
- **WebSocket Handler**: Manages WebSocket connections and graphql-ws protocol
- **HTTP Handler**: Handles GraphQL queries and mutations

### Frontend (JavaScript)

The client:
- Connects via WebSocket for subscriptions
- Sends mutations via HTTP POST
- Implements the graphql-ws protocol
- Automatically reconnects on disconnect
- Displays messages in real-time

## GraphQL Schema

```graphql
type Message {
  id: String!
  text: String!
  author: String!
}

type Query {
  hello: String
}

type Mutation {
  sendMessage(text: String!, author: String!): Message
}

type Subscription {
  messageAdded: Message
}
```

## Testing with GraphQL Clients

### Using curl for mutations:

```bash
curl -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { sendMessage(text: \"Hello from curl!\", author: \"Terminal User\") { id text author } }"
  }'
```

### Using a GraphQL client (like Altair or GraphQL Playground):

**Subscription:**
```graphql
subscription {
  messageAdded {
    id
    text
    author
  }
}
```

**Mutation:**
```graphql
mutation SendMessage($text: String!, $author: String!) {
  sendMessage(text: $text, author: $author) {
    id
    text
    author
  }
}
```

Variables:
```json
{
  "text": "Hello, world!",
  "author": "Alice"
}
```

## Architecture

```
┌─────────────────┐
│  Web Browser    │
│  (chat_client)  │
└────────┬────────┘
         │
         │ WebSocket (subscriptions)
         │ HTTP POST (mutations)
         │
         ▼
┌─────────────────────────────────┐
│  Crystal Server                 │
│  (subscription_example.cr)      │
│                                 │
│  ┌──────────────────────────┐  │
│  │ WebSocketHandler         │  │
│  │ - graphql-ws protocol    │  │
│  │ - subscription mgmt      │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ GraphQLHandler           │  │
│  │ - HTTP mutations         │  │
│  │ - Query execution        │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ MESSAGE_CHANNEL          │  │
│  │ - Broadcasts events      │  │
│  │ - Connects subs & muts   │  │
│  └──────────────────────────┘  │
└─────────────────────────────────┘
```

## Code Structure

### Server Components

- **Schema Definition**: GraphQL types (Message, Query, Mutation, Subscription)
- **Global Channel**: `MESSAGE_CHANNEL` broadcasts messages to all subscribers
- **WebSocket Handler**: Manages subscription connections
- **HTTP Handler**: Processes mutations and queries
- **Event Streaming**: Each subscription gets its own channel that receives from global channel

### Client Components

- **WebSocket Connection**: Maintains connection to server
- **Subscription Management**: Subscribes to `messageAdded` on connect
- **Mutation Sending**: HTTP POST for sending messages
- **UI Updates**: Real-time message display with animations
- **Auto-Reconnect**: Automatically reconnects on disconnect

## Troubleshooting

### Server won't start
- Make sure port 4000 is available
- Check that all dependencies are installed: `shards install`

### Client can't connect
- Verify the server is running
- Check browser console for errors
- Ensure WebSocket URL is correct (ws://localhost:4000/graphql)

### Messages not appearing
- Check browser console for subscription errors
- Verify the mutation succeeded (check network tab)
- Try refreshing the page

## Next Steps

Try modifying the example to:
- Add message persistence
- Implement chat rooms
- Add user authentication
- Show typing indicators
- Add message timestamps on server side
- Implement message editing/deletion

## Learn More

See the main documentation for more details:
- [SUBSCRIPTIONS.md](../SUBSCRIPTIONS.md) - Comprehensive subscription guide
- [SUBSCRIPTION_PLAN.md](../SUBSCRIPTION_PLAN.md) - Implementation plan
- [SUBSCRIPTION_IMPLEMENTATION_SUMMARY.md](../SUBSCRIPTION_IMPLEMENTATION_SUMMARY.md) - Implementation details
