# GraphQL Subscription Implementation Plan

## Overview

This document outlines the comprehensive plan for implementing GraphQL subscription support in Oxide, following the [GraphQL Specification (September 2025) Section 6.2.3](https://spec.graphql.org/September2025/#sec-Subscription).

**Current Status**: Not implemented (intentionally deferred)  
**Estimated Effort**: 8-12 weeks  
**Complexity**: High  
**Dependencies**: Crystal async/fiber support, event streaming infrastructure

---

## Background

GraphQL subscriptions allow clients to maintain real-time connections to the server and receive updates when specific events occur. Unlike queries and mutations which are request/response, subscriptions are long-lived and event-driven.

### Key Differences from Queries/Mutations

| Aspect | Query/Mutation | Subscription |
|--------|----------------|--------------|
| Execution | Single request/response | Long-lived connection |
| Data Flow | Pull (client requests) | Push (server sends) |
| Result Count | One result | Stream of results |
| Protocol | HTTP (typically) | WebSocket/SSE/HTTP2 |
| Validation | Standard rules | Additional rules (single root field) |

---

## Phase 1: Schema & Type System (2 weeks)

### 1.1 Add Subscription Root Type to Schema

**File**: `src/oxide/schema.cr`

**Current State**:
```crystal
class Schema
  getter query : Types::ObjectType
  getter mutation : Types::ObjectType?
  # Missing: subscription
end
```

**Required Changes**:
```crystal
class Schema
  getter query : Types::ObjectType
  getter mutation : Types::ObjectType?
  getter subscription : Types::ObjectType?  # ADD THIS
  
  def initialize(
    @query : Types::ObjectType,
    @mutation : Types::ObjectType? = nil,
    @subscription : Types::ObjectType? = nil,  # ADD THIS
    @directives = default_directives,
    @orphan_types = [] of Type,
    @description : String? = nil
  )
  end
end
```

**Tasks**:
- [ ] Add `subscription` property to Schema class
- [ ] Update Schema initialization
- [ ] Update introspection to include subscription type
- [ ] Add tests for schema with subscription root

**Estimated Time**: 2 days

---

### 1.2 Subscription Field Type

**File**: `src/oxide/field.cr` (new variant)

**Concept**: Subscription fields are different from regular fields because they need:
1. A `subscribe` function that creates the event stream
2. A `resolve` function that transforms events into results

**Design Option 1 - Extend Existing Field**:
```crystal
class Field(I, O)
  # Existing properties
  getter type : Type
  getter resolve : Proc(I, Resolution, O)
  
  # New for subscriptions
  getter subscribe : Proc(I, Resolution, EventStream)?
  
  def initialize(
    @type,
    resolve : Proc(I, Resolution, O)? = nil,
    subscribe : Proc(I, Resolution, EventStream)? = nil,
    # ... other params
  )
  end
end
```

**Design Option 2 - Separate SubscriptionField** (RECOMMENDED):
```crystal
class SubscriptionField(I, O) < Field(I, O)
  getter subscribe : Proc(I, Resolution, EventStream)
  getter resolve : Proc(O, Resolution, O)  # Transforms event to result
  
  def initialize(
    @type,
    @subscribe,
    @resolve,
    # ... other params
  )
  end
end
```

**Tasks**:
- [ ] Design subscription field architecture (choose option)
- [ ] Implement SubscriptionField class or extend Field
- [ ] Add type checking for subscription fields
- [ ] Document API with examples
- [ ] Add unit tests

**Estimated Time**: 3 days

---

### 1.3 Event Stream Abstraction

**File**: `src/oxide/execution/event_stream.cr` (NEW)

**Purpose**: Abstraction over different event sources (channels, observables, async iterators)

**Proposed Interface**:
```crystal
module Oxide
  module Execution
    # Abstract base for event streams
    abstract class EventStream(T)
      # Subscribe to events with a callback
      abstract def subscribe(&block : T ->)
      
      # Unsubscribe/cleanup
      abstract def close
      
      # Check if stream is still active
      abstract def closed? : Bool
    end
    
    # Channel-based implementation
    class ChannelEventStream(T) < EventStream(T)
      def initialize(@channel : Channel(T))
      end
      
      def subscribe(&block : T ->)
        spawn do
          loop do
            break if @channel.closed?
            value = @channel.receive
            block.call(value)
          rescue Channel::ClosedError
            break
          end
        end
      end
      
      def close
        @channel.close
      end
      
      def closed? : Bool
        @channel.closed?
      end
    end
    
    # Async iterator implementation
    class AsyncIteratorEventStream(T) < EventStream(T)
      def initialize(@iterator : Iterator(T))
      end
      
      def subscribe(&block : T ->)
        spawn do
          @iterator.each { |value| block.call(value) }
        end
      end
      
      def close
        # No-op for iterators
      end
      
      def closed? : Bool
        false
      end
    end
  end
end
```

**Tasks**:
- [ ] Design EventStream interface
- [ ] Implement ChannelEventStream
- [ ] Implement AsyncIteratorEventStream
- [ ] Consider fiber-safe implementations
- [ ] Add comprehensive tests
- [ ] Document usage patterns

**Estimated Time**: 5 days

---

## Phase 2: Validation Rules (1 week)

### 2.1 Single Root Field Validation

**Spec Reference**: [Section 5.2.4.1](https://spec.graphql.org/September2025/#sec-Single-root-field)

**File**: `src/oxide/validation/rules/single_root_field.cr` (NEW)

**Requirements**:
1. Subscription operations must have exactly one root field
2. Introspection fields (`__typename`, `__schema`, `__type`) don't count as the root field
3. `@skip` and `@include` directives cannot be used to conditionally select the root field
4. Fragment spreads can be used if they ultimately result in one field

**Implementation**:
```crystal
module Oxide
  module Validation
    class SingleRootField < Rule
      def enter(node : Oxide::Language::Nodes::OperationDefinition, context)
        return unless node.operation_type == "subscription"
        
        # Collect root fields (excluding introspection)
        root_fields = collect_root_fields(node.selection_set, context)
        
        if root_fields.size == 0
          context.errors << ValidationError.new(
            "Subscription operation must have exactly one root field."
          )
        elsif root_fields.size > 1
          context.errors << ValidationError.new(
            "Subscription \"#{node.name}\" must select only one field. Found: #{root_fields.join(", ")}."
          )
        end
        
        # Check for @skip/@include on root level
        if has_conditional_directives?(node.selection_set)
          context.errors << ValidationError.new(
            "Subscription \"#{node.name}\" must not use @skip or @include directives at root level."
          )
        end
      end
      
      private def collect_root_fields(selection_set, context) : Array(String)
        fields = [] of String
        
        selection_set.selections.each do |selection|
          case selection
          when Oxide::Language::Nodes::Field
            # Skip introspection fields
            next if selection.name.starts_with?("__")
            fields << selection.name
          when Oxide::Language::Nodes::FragmentSpread
            # Recursively collect from fragment
            fragment = context.fragments[selection.name]?
            if fragment
              fields.concat(collect_root_fields(fragment.selection_set, context))
            end
          when Oxide::Language::Nodes::InlineFragment
            fields.concat(collect_root_fields(selection.selection_set, context))
          end
        end
        
        fields.uniq
      end
      
      private def has_conditional_directives?(selection_set) : Bool
        selection_set.selections.any? do |selection|
          case selection
          when Oxide::Language::Nodes::Field
            selection.directives.any? { |d| d.name == "skip" || d.name == "include" }
          else
            false
          end
        end
      end
    end
  end
end
```

**Test Cases** (from spec):
- [ ] **Example #115**: Valid single root field subscription
- [ ] **Example #116**: Valid subscription with fragment spread
- [ ] **Example #117**: INVALID - Multiple root fields
- [ ] **Example #118**: INVALID - Multiple fields via fragment spread
- [ ] **Example #119**: INVALID - `@skip`/`@include` on root
- [ ] **Example #120**: INVALID - `__typename` as sole field

**Tasks**:
- [ ] Implement SingleRootField validation rule
- [ ] Add to validation runtime
- [ ] Implement all 6 spec test cases
- [ ] Test edge cases (nested fragments, multiple inline fragments)
- [ ] Add "Did you mean?" suggestions for typos

**Estimated Time**: 4 days

---

### 2.2 Update Operation Type Existence

**File**: `src/oxide/validation/rules/operation_type_existence.cr`

**Current State**: Only validates query and mutation

**Required Changes**:
```crystal
def enter(node : Oxide::Language::Nodes::OperationDefinition, context)
  operation_type = node.operation_type

  case operation_type
  when "query"
    # ... existing query validation
  when "mutation"
    # ... existing mutation validation
  when "subscription"
    if context.schema.subscription.nil?
      context.errors << ValidationError.new(
        "Schema does not support subscriptions."
      )
    end
  end
end
```

**Tasks**:
- [ ] Add subscription case to operation type checking
- [ ] Add test for missing subscription schema
- [ ] Update error messages

**Estimated Time**: 1 day

---

## Phase 3: Execution Engine (3-4 weeks)

### 3.1 CreateSourceEventStream Algorithm

**Spec Reference**: [Section 6.2.3.1](https://spec.graphql.org/September2025/#sec-CreateSourceEventStream)

**File**: `src/oxide/execution/subscription_runtime.cr` (NEW)

**Purpose**: Create the initial event stream from the subscription field

**Algorithm** (from spec):
```
CreateSourceEventStream(subscription, schema, variableValues, initialValue):
  1. Let {subscriptionType} be the root Subscription type in {schema}.
  2. Assert: {subscriptionType} is an Object type.
  3. Let {selectionSet} be the top level Selection Set in {subscription}.
  4. Let {rootField} be the first top level field in {selectionSet} (must be exactly one).
  5. Let {argumentValues} be the result of {CoerceArgumentValues(subscriptionType, rootField, variableValues)}.
  6. Let {fieldStream} be the result of running {ResolveFieldEventStream(subscriptionType, initialValue, rootField, argumentValues)}.
  7. Return {fieldStream}.
```

**Implementation**:
```crystal
module Oxide
  module Execution
    class SubscriptionRuntime
      def self.create_source_event_stream(
        subscription : Query,
        schema : Schema,
        variable_values : Hash(String, JSON::Any),
        initial_value : JSON::Any?
      ) : EventStream | ExecutionError
        
        subscription_type = schema.subscription
        return ExecutionError.new("Schema does not support subscriptions") if subscription_type.nil?
        
        # Get the operation definition
        operation = get_subscription_operation(subscription)
        return ExecutionError.new("No subscription operation found") if operation.nil?
        
        # Get the single root field (validated earlier)
        root_field = get_root_field(operation.selection_set)
        return ExecutionError.new("No root field found") if root_field.nil?
        
        # Get field definition
        field_name = root_field.name
        field_def = subscription_type.fields[field_name]?
        return ExecutionError.new("Field #{field_name} not found") if field_def.nil?
        
        # Coerce arguments
        argument_values = coerce_argument_values(
          subscription_type,
          field_def,
          root_field,
          variable_values
        )
        
        # Resolve field event stream
        resolve_field_event_stream(
          subscription_type,
          initial_value,
          field_def,
          argument_values
        )
      end
      
      private def self.resolve_field_event_stream(
        object_type : Types::ObjectType,
        object_value : JSON::Any?,
        field : Field,
        argument_values : Hash(String, JSON::Any)
      ) : EventStream
        
        # Call the subscribe function
        resolution = Resolution.new(
          schema: schema,
          arguments: argument_values,
          # ... other context
        )
        
        field.subscribe.call(object_value, resolution)
      end
    end
  end
end
```

**Tasks**:
- [ ] Implement CreateSourceEventStream algorithm
- [ ] Handle errors during stream creation
- [ ] Add timeout/cancellation support
- [ ] Test with various field types
- [ ] Document subscribe function contract

**Estimated Time**: 5 days

---

### 3.2 MapSourceToResponseEvent Algorithm

**Spec Reference**: [Section 6.2.3.2](https://spec.graphql.org/September2025/#sec-MapSourceToResponseEvent)

**Purpose**: Transform each event from the source stream into a GraphQL response

**Algorithm** (from spec):
```
MapSourceToResponseEvent(subscription, schema, variableValues):
  1. Let {sourceStream} be the result of {CreateSourceEventStream(subscription, schema, variableValues)}.
  2. Return a stream which yields events as follows:
     - For each {event} in {sourceStream}:
       1. Let {response} be the result of {ExecuteSubscriptionEvent(subscription, schema, event, variableValues)}.
       2. Yield {response}.
```

**Implementation**:
```crystal
module Oxide
  module Execution
    class SubscriptionRuntime
      def self.map_source_to_response_event(
        subscription : Query,
        schema : Schema,
        variable_values : Hash(String, JSON::Any)
      ) : EventStream(Response)
        
        # Create source event stream
        source_stream = create_source_event_stream(
          subscription,
          schema,
          variable_values,
          nil
        )
        
        return source_stream if source_stream.is_a?(ExecutionError)
        
        # Create response stream
        ResponseEventStream.new(source_stream) do |event|
          execute_subscription_event(
            subscription,
            schema,
            event,
            variable_values
          )
        end
      end
      
      private def self.execute_subscription_event(
        subscription : Query,
        schema : Schema,
        event : JSON::Any,
        variable_values : Hash(String, JSON::Any)
      ) : Response
        
        # Execute the subscription operation with the event as the root value
        execution_context = ExecutionContext.new(
          schema: schema,
          variables: variable_values,
          root_value: event
        )
        
        # Standard execution (similar to query execution)
        Runtime.execute_operation(
          subscription,
          schema,
          execution_context
        )
      end
    end
    
    # Wrapper that transforms source events to responses
    class ResponseEventStream < EventStream(Response)
      def initialize(@source : EventStream, &@transform : JSON::Any -> Response)
      end
      
      def subscribe(&block : Response ->)
        @source.subscribe do |event|
          response = @transform.call(event)
          block.call(response)
        end
      end
      
      def close
        @source.close
      end
      
      def closed? : Bool
        @source.closed?
      end
    end
  end
end
```

**Tasks**:
- [ ] Implement MapSourceToResponseEvent algorithm
- [ ] Create ResponseEventStream wrapper
- [ ] Handle errors in event transformation
- [ ] Test with various event types
- [ ] Add performance monitoring

**Estimated Time**: 5 days

---

### 3.3 Subscription Execution Runtime

**File**: `src/oxide/execution/runtime.cr` (EXTEND)

**Purpose**: Add subscription execution path to main runtime

**Changes**:
```crystal
class Runtime
  def execute_subscription(
    schema : Schema,
    query : Query,
    variables : Hash(String, JSON::Any) = {} of String => JSON::Any
  ) : EventStream(Response)
    
    # Validate subscription
    validation_runtime = Validation::Runtime.new(schema, query)
    validation_runtime.execute
    
    if validation_runtime.errors?
      # Return error stream
      return ErrorEventStream.new(validation_runtime.errors)
    end
    
    # Execute subscription
    SubscriptionRuntime.map_source_to_response_event(
      query,
      schema,
      variables
    )
  end
end

# Error stream for validation errors
class ErrorEventStream < EventStream(Response)
  def initialize(@errors : Array(ValidationError))
  end
  
  def subscribe(&block : Response ->)
    response = Response.new(nil, @errors)
    block.call(response)
  end
  
  def close
  end
  
  def closed? : Bool
    true
  end
end
```

**Tasks**:
- [ ] Add execute_subscription method to Runtime
- [ ] Integrate validation
- [ ] Handle execution errors
- [ ] Add error event stream
- [ ] Test end-to-end subscription execution

**Estimated Time**: 4 days

---

## Phase 4: Transport Layer (2-3 weeks)

### 4.1 WebSocket Protocol Support

**File**: `src/oxide/transport/websocket_handler.cr` (NEW)

**Purpose**: Implement GraphQL over WebSocket protocol

**Protocol**: [graphql-ws protocol](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md)

**Message Types**:
- `ConnectionInit` - Client initiates connection
- `ConnectionAck` - Server acknowledges connection
- `Subscribe` - Client subscribes to operation
- `Next` - Server sends data event
- `Error` - Server sends error
- `Complete` - Subscription completed
- `Ping` / `Pong` - Keep-alive

**Implementation**:
```crystal
require "http/web_socket"

module Oxide
  module Transport
    class WebSocketHandler
      @subscriptions = {} of String => EventStream(Response)
      @socket : HTTP::WebSocket
      @schema : Schema
      
      def initialize(@socket, @schema)
      end
      
      def handle
        @socket.on_message do |message|
          handle_message(message)
        end
        
        @socket.on_close do
          cleanup_subscriptions
        end
        
        @socket.run
      end
      
      private def handle_message(message : String)
        data = JSON.parse(message)
        type = data["type"].as_s
        
        case type
        when "connection_init"
          handle_connection_init(data)
        when "subscribe"
          handle_subscribe(data)
        when "complete"
          handle_complete(data)
        when "ping"
          handle_ping
        else
          send_error("Unknown message type: #{type}")
        end
      rescue ex
        send_error(ex.message)
      end
      
      private def handle_connection_init(data)
        # Optional: Validate connection parameters
        send_message({
          type: "connection_ack"
        })
      end
      
      private def handle_subscribe(data)
        id = data["id"].as_s
        payload = data["payload"]
        
        query_string = payload["query"].as_s
        variables = payload["variables"]?.try(&.as_h) || {} of String => JSON::Any
        operation_name = payload["operationName"]?.try(&.as_s)
        
        # Parse and execute subscription
        query = Query.new(query_string)
        event_stream = Runtime.execute_subscription(@schema, query, variables)
        
        # Store subscription
        @subscriptions[id] = event_stream
        
        # Subscribe to events
        event_stream.subscribe do |response|
          send_message({
            id: id,
            type: "next",
            payload: response.to_json
          })
        end
        
      rescue ex
        send_message({
          id: id,
          type: "error",
          payload: [{message: ex.message}]
        })
      end
      
      private def handle_complete(data)
        id = data["id"].as_s
        subscription = @subscriptions.delete(id)
        subscription.try(&.close)
      end
      
      private def handle_ping
        send_message({type: "pong"})
      end
      
      private def send_message(data)
        @socket.send(data.to_json)
      end
      
      private def send_error(message : String)
        send_message({
          type: "error",
          payload: [{message: message}]
        })
      end
      
      private def cleanup_subscriptions
        @subscriptions.each_value(&.close)
        @subscriptions.clear
      end
    end
  end
end
```

**Tasks**:
- [ ] Implement WebSocket message handling
- [ ] Support graphql-ws protocol
- [ ] Add connection lifecycle management
- [ ] Implement keep-alive (ping/pong)
- [ ] Add authentication/authorization hooks
- [ ] Test with WebSocket client library
- [ ] Add integration tests

**Estimated Time**: 6 days

---

### 4.2 HTTP Streaming (Server-Sent Events)

**File**: `src/oxide/transport/sse_handler.cr` (NEW)

**Purpose**: Alternative to WebSocket using Server-Sent Events

**Protocol**: HTTP with `Content-Type: text/event-stream`

**Implementation**:
```crystal
module Oxide
  module Transport
    class SSEHandler
      def self.handle(context : HTTP::Server::Context, schema : Schema, query : Query, variables : Hash(String, JSON::Any))
        context.response.content_type = "text/event-stream"
        context.response.headers["Cache-Control"] = "no-cache"
        context.response.headers["Connection"] = "keep-alive"
        
        # Execute subscription
        event_stream = Runtime.execute_subscription(schema, query, variables)
        
        # Stream events
        event_stream.subscribe do |response|
          write_sse_event(context.response, response)
        end
        
      rescue ex
        write_sse_error(context.response, ex.message)
      ensure
        event_stream.try(&.close)
      end
      
      private def self.write_sse_event(response : HTTP::Server::Response, data : Response)
        response << "event: next\n"
        response << "data: #{data.to_json}\n\n"
        response.flush
      end
      
      private def self.write_sse_error(response : HTTP::Server::Response, message : String)
        response << "event: error\n"
        response << "data: #{{"message" => message}.to_json}\n\n"
        response.flush
      end
    end
  end
end
```

**Tasks**:
- [ ] Implement SSE event streaming
- [ ] Handle client disconnection
- [ ] Add keep-alive support
- [ ] Test with EventSource client
- [ ] Document limitations vs WebSocket

**Estimated Time**: 3 days

---

### 4.3 HTTP Multipart Response (Incremental Delivery)

**File**: `src/oxide/transport/multipart_handler.cr` (NEW)

**Purpose**: Support `@defer` and `@stream` directives (future)

**Note**: While not strictly required for subscriptions, this transport mechanism is becoming standard for incremental delivery.

**Tasks**:
- [ ] Research multipart/mixed protocol
- [ ] Design implementation strategy
- [ ] Defer to future phase (optional)

**Estimated Time**: Deferred

---

## Phase 5: Testing & Examples (2 weeks)

### 5.1 Unit Tests

**Coverage Required**:
- [ ] Schema with subscription root type
- [ ] SubscriptionField class
- [ ] EventStream implementations
- [ ] SingleRootField validation rule
- [ ] CreateSourceEventStream algorithm
- [ ] MapSourceToResponseEvent algorithm
- [ ] WebSocket protocol handling
- [ ] SSE streaming
- [ ] Error handling at all layers

**Estimated Time**: 5 days

---

### 5.2 Integration Tests

**Scenarios**:
- [ ] End-to-end subscription via WebSocket
- [ ] End-to-end subscription via SSE
- [ ] Multiple concurrent subscriptions
- [ ] Subscription with variables
- [ ] Subscription with complex selection sets
- [ ] Subscription error handling
- [ ] Client disconnection handling
- [ ] Server-side subscription cancellation

**Example Test**:
```crystal
describe "Subscription Integration" do
  it "streams events via WebSocket" do
    # Setup schema with subscription
    message_channel = Channel(String).new
    
    subscription_type = Oxide::Types::ObjectType.new(
      name: "Subscription",
      fields: {
        "messageAdded" => Oxide::SubscriptionField.new(
          type: Oxide::Types::StringType.new,
          subscribe: ->(obj : Nil, res : Resolution) {
            Oxide::ChannelEventStream.new(message_channel)
          },
          resolve: ->(message : String, res : Resolution) {
            message
          }
        )
      }
    )
    
    schema = Oxide::Schema.new(
      query: query_type,
      subscription: subscription_type
    )
    
    # Connect WebSocket client
    ws = WebSocket.new("ws://localhost:3000/graphql")
    
    # Send connection_init
    ws.send({type: "connection_init"}.to_json)
    
    # Wait for connection_ack
    msg = JSON.parse(ws.receive)
    msg["type"].should eq("connection_ack")
    
    # Subscribe
    ws.send({
      id: "1",
      type: "subscribe",
      payload: {
        query: "subscription { messageAdded }"
      }
    }.to_json)
    
    # Publish message
    message_channel.send("Hello World")
    
    # Receive event
    msg = JSON.parse(ws.receive)
    msg["type"].should eq("next")
    msg["payload"]["data"]["messageAdded"].should eq("Hello World")
    
    # Complete subscription
    ws.send({id: "1", type: "complete"}.to_json)
  end
end
```

**Estimated Time**: 5 days

---

### 5.3 Example Applications

**Examples to Create**:

1. **Chat Application**
   - Subscribe to new messages
   - Real-time message updates
   - User typing indicators

2. **Live Dashboard**
   - Subscribe to metric updates
   - Real-time data visualization
   - Multiple concurrent subscriptions

3. **Notification System**
   - Subscribe to user notifications
   - Different notification types
   - Filtered subscriptions

**Structure**:
```
examples/
  ├── chat/
  │   ├── schema.cr
  │   ├── server.cr
  │   ├── client.html
  │   └── README.md
  ├── dashboard/
  │   ├── schema.cr
  │   ├── server.cr
  │   ├── client.html
  │   └── README.md
  └── notifications/
      ├── schema.cr
      ├── server.cr
      ├── client.html
      └── README.md
```

**Estimated Time**: 4 days

---

## Phase 6: Documentation (1 week)

### 6.1 API Documentation

**Documents to Create**:

1. **SUBSCRIPTIONS.md** - Comprehensive guide
   - Overview and concepts
   - Schema design best practices
   - Subscribe function contract
   - Event stream patterns
   - Error handling
   - Performance considerations

2. **API Reference**
   - SubscriptionField API
   - EventStream API
   - WebSocket protocol reference
   - SSE protocol reference

3. **Migration Guide**
   - Adding subscriptions to existing schema
   - Converting polling to subscriptions
   - Common pitfalls

**Estimated Time**: 3 days

---

### 6.2 Update Existing Documentation

**Files to Update**:
- [ ] `README.md` - Add subscription support to features
- [ ] `PROGRESS.md` - Mark Milestone 7 as complete
- [ ] `ERROR_MESSAGES.md` - Add subscription validation errors
- [ ] `plan.md` - Update implementation status

**Estimated Time**: 1 day

---

### 6.3 Code Examples & Tutorials

**Tutorials to Write**:

1. **Getting Started with Subscriptions**
   - Simple "hello world" subscription
   - WebSocket client setup
   - Testing subscriptions

2. **Advanced Subscription Patterns**
   - Filtered subscriptions
   - Parameterized subscriptions
   - Combining with queries/mutations

3. **Performance & Scaling**
   - Connection management
   - Memory considerations
   - Redis pub/sub integration

**Estimated Time**: 2 days

---

## Phase 7: Performance & Production Readiness (2 weeks)

### 7.1 Performance Optimization

**Areas to Optimize**:

1. **Connection Management**
   - Connection pooling
   - Resource cleanup
   - Memory leak prevention

2. **Event Distribution**
   - Efficient pub/sub patterns
   - Minimize duplicate work
   - Batch event processing

3. **Scalability**
   - Horizontal scaling strategy
   - Redis/NATS integration for multi-instance
   - Connection count monitoring

**Tasks**:
- [ ] Profile memory usage under load
- [ ] Benchmark concurrent subscriptions
- [ ] Test with thousands of connections
- [ ] Implement connection limits
- [ ] Add metrics and monitoring

**Estimated Time**: 5 days

---

### 7.2 Error Handling & Recovery

**Error Scenarios to Handle**:

1. **Network Errors**
   - Client disconnection
   - Server restart
   - Network interruption

2. **Application Errors**
   - Subscribe function throws
   - Resolve function throws
   - Invalid event data

3. **Resource Errors**
   - Out of memory
   - Too many connections
   - Event queue overflow

**Implementation**:
```crystal
class SubscriptionErrorHandler
  def self.handle_subscribe_error(ex : Exception, subscription_id : String)
    # Log error
    Log.error { "Subscription #{subscription_id} failed: #{ex.message}" }
    
    # Send error to client
    send_error_event(subscription_id, ex.message)
    
    # Cleanup resources
    cleanup_subscription(subscription_id)
  end
  
  def self.handle_event_error(ex : Exception, subscription_id : String, event : JSON::Any)
    # Log with context
    Log.warn { "Event processing failed for #{subscription_id}: #{ex.message}" }
    
    # Continue subscription (don't terminate on single event error)
    send_partial_error(subscription_id, ex.message)
  end
end
```

**Tasks**:
- [ ] Implement error handlers for all layers
- [ ] Add error recovery strategies
- [ ] Test error scenarios
- [ ] Document error handling behavior
- [ ] Add graceful degradation

**Estimated Time**: 4 days

---

### 7.3 Security Considerations

**Security Checklist**:

1. **Authentication & Authorization**
   - [ ] Support auth in connection_init
   - [ ] Per-subscription authorization
   - [ ] Field-level permissions
   - [ ] Token refresh mechanism

2. **Rate Limiting**
   - [ ] Connection rate limits
   - [ ] Subscription count per connection
   - [ ] Event delivery rate limits
   - [ ] Backpressure handling

3. **Resource Protection**
   - [ ] Max connection timeout
   - [ ] Max subscription lifetime
   - [ ] Event queue size limits
   - [ ] Memory usage monitoring

4. **Data Security**
   - [ ] TLS/WSS enforcement
   - [ ] Sensitive data filtering
   - [ ] Audit logging

**Implementation Example**:
```crystal
class SubscriptionAuthorizer
  def self.authorize_connection(context : AuthContext) : Bool
    # Validate auth token
    token = context.connection_params["authToken"]?
    return false unless token
    
    verify_token(token)
  end
  
  def self.authorize_subscription(
    context : AuthContext,
    operation : Query
  ) : Bool
    # Check user permissions for subscription
    user = context.current_user
    return false unless user
    
    # Extract subscription field
    field_name = extract_root_field(operation)
    
    # Check permissions
    user.can_subscribe_to?(field_name)
  end
end
```

**Tasks**:
- [ ] Implement authentication layer
- [ ] Add authorization checks
- [ ] Implement rate limiting
- [ ] Add resource quotas
- [ ] Security audit
- [ ] Penetration testing

**Estimated Time**: 5 days

---

## Technical Challenges & Considerations

### Challenge 1: Concurrency & Thread Safety

**Issue**: Subscriptions are inherently concurrent - multiple clients, multiple events

**Solutions**:
- Use Crystal's fiber-based concurrency
- Channel-based communication between fibers
- Mutex protection for shared state
- Consider actor pattern for subscription management

**Example**:
```crystal
class SubscriptionManager
  @subscriptions = {} of String => Subscription
  @mutex = Mutex.new
  
  def add_subscription(id : String, sub : Subscription)
    @mutex.synchronize do
      @subscriptions[id] = sub
    end
  end
  
  def remove_subscription(id : String)
    @mutex.synchronize do
      @subscriptions.delete(id)
    end
  end
end
```

---

### Challenge 2: Memory Management

**Issue**: Long-lived connections can accumulate memory

**Solutions**:
- Implement connection lifecycle hooks
- Automatic cleanup on disconnect
- Periodic memory profiling
- Event queue size limits
- Weak references where applicable

---

### Challenge 3: Event Source Integration

**Issue**: Need to integrate with various event sources (Redis, Kafka, NATS, etc.)

**Solutions**:
- Abstract EventStream interface
- Pluggable adapters for different sources
- Document adapter API
- Provide common adapters out-of-box

**Example Adapters**:
```crystal
# Redis Pub/Sub adapter
class RedisEventStream < EventStream(String)
  def initialize(@redis : Redis::Client, @channel : String)
  end
  
  def subscribe(&block : String ->)
    @redis.subscribe(@channel) do |message|
      block.call(message)
    end
  end
end

# NATS adapter
class NatsEventStream < EventStream(String)
  def initialize(@nats : NATS::Client, @subject : String)
  end
  
  def subscribe(&block : String ->)
    @nats.subscribe(@subject) do |msg|
      block.call(msg.data)
    end
  end
end
```

---

### Challenge 4: Testing Long-Lived Connections

**Issue**: Subscriptions are hard to test due to asynchronous nature

**Solutions**:
- Test event streams in isolation
- Mock event sources
- Use channels for synchronization in tests
- Create test helpers for common patterns

**Example Test Helper**:
```crystal
class SubscriptionTestHelper
  def self.with_subscription(query : String, &block)
    events = Channel(Response).new
    
    # Setup subscription
    stream = execute_subscription(query)
    stream.subscribe { |response| events.send(response) }
    
    # Yield control with event channel
    yield events
    
  ensure
    stream.try(&.close)
  end
end

# Usage
it "receives events" do
  SubscriptionTestHelper.with_subscription("subscription { test }") do |events|
    # Trigger event
    publish_test_event("data")
    
    # Receive and verify
    response = events.receive
    response.data["test"].should eq("data")
  end
end
```

---

## Dependencies & Prerequisites

### Required Libraries

1. **WebSocket Support**
   - Crystal's built-in `HTTP::WebSocket`
   - Or: [websocket.cr](https://github.com/crystal-lang/crystal/blob/master/src/http/web_socket.cr)

2. **Async/Concurrency**
   - Crystal's fiber support (built-in)
   - Channels (built-in)

3. **Event Sources** (Optional, for examples)
   - [redis.cr](https://github.com/stefanwille/crystal-redis) for Redis pub/sub
   - [nats.cr](https://github.com/nats-io/nats.cr) for NATS
   - [kafka.cr](https://github.com/karafka/kafka.cr) for Kafka

### Infrastructure Requirements

1. **Development**
   - Crystal 1.16+ (for latest async features)
   - Redis or similar for pub/sub (examples)
   - WebSocket-capable HTTP server

2. **Production**
   - Load balancer with WebSocket support
   - Sticky sessions or shared pub/sub
   - Monitoring for connection counts

---

## Timeline Summary

| Phase | Duration | Dependencies |
|-------|----------|-------------|
| Phase 1: Schema & Type System | 2 weeks | None |
| Phase 2: Validation Rules | 1 week | Phase 1 |
| Phase 3: Execution Engine | 3-4 weeks | Phase 1 |
| Phase 4: Transport Layer | 2-3 weeks | Phase 3 |
| Phase 5: Testing & Examples | 2 weeks | Phase 4 |
| Phase 6: Documentation | 1 week | Phase 5 |
| Phase 7: Production Ready | 2 weeks | Phase 5 |
| **Total** | **13-15 weeks** | |

**Recommended Team Size**: 2-3 developers

**Parallel Work Opportunities**:
- Phase 1 & 2 can overlap (different developers)
- Phase 5 can start once Phase 4 basics are done
- Phase 6 can be done alongside Phase 7

---

## Success Criteria

### Must Have
- [ ] Schema supports subscription root type
- [ ] SingleRootField validation rule implemented
- [ ] CreateSourceEventStream algorithm working
- [ ] MapSourceToResponseEvent algorithm working
- [ ] WebSocket transport functional
- [ ] All spec examples (#115-#120) passing
- [ ] End-to-end integration tests passing
- [ ] Memory leaks prevented
- [ ] Graceful error handling

### Should Have
- [ ] SSE transport support
- [ ] Redis/NATS adapters
- [ ] Connection rate limiting
- [ ] Authentication support
- [ ] Performance benchmarks
- [ ] Example applications
- [ ] Comprehensive documentation

### Nice to Have
- [ ] Multipart response support (@defer/@stream)
- [ ] GraphQL playground integration
- [ ] Subscription analytics/monitoring
- [ ] Auto-reconnect support
- [ ] Subscription batching

---

## Risk Assessment

### High Risk
1. **Concurrency Bugs**: Thread safety issues are hard to debug
   - Mitigation: Extensive concurrent testing, use proven patterns
   
2. **Memory Leaks**: Long-lived connections can leak
   - Mitigation: Automatic cleanup, memory profiling, resource limits

3. **Performance Degradation**: Many connections impact server
   - Mitigation: Benchmarking, connection limits, horizontal scaling

### Medium Risk
1. **WebSocket Protocol Complexity**: Many edge cases
   - Mitigation: Use established protocol (graphql-ws), thorough testing

2. **Error Handling Coverage**: Many failure modes
   - Mitigation: Systematic error scenarios, fault injection testing

### Low Risk
1. **API Stability**: Subscription API might change
   - Mitigation: Follow GraphQL spec closely, version carefully

---

## Alternatives Considered

### Alternative 1: Polling Instead of Subscriptions
**Pros**: Simpler to implement, uses standard HTTP  
**Cons**: Inefficient, increased latency, server load  
**Decision**: Not recommended for real-time use cases

### Alternative 2: Third-Party Service (e.g., Pusher, Ably)
**Pros**: No implementation needed, managed infrastructure  
**Cons**: External dependency, cost, vendor lock-in  
**Decision**: Could be used but Oxide should provide native support

### Alternative 3: Server-Sent Events Only (No WebSocket)
**Pros**: Simpler protocol, HTTP-based  
**Cons**: Unidirectional, connection limits  
**Decision**: Support both SSE and WebSocket

---

## Future Enhancements

### Beyond Initial Implementation

1. **Subscription Filters**
   - Server-side event filtering
   - Reduce unnecessary client events
   - GraphQL argument-based filtering

2. **Subscription Batching**
   - Combine multiple subscription results
   - Reduce network overhead
   - Configurable batch windows

3. **Live Queries**
   - Auto-updating query results
   - No explicit subscription needed
   - Cache invalidation integration

4. **Federation Support**
   - Subscriptions across federated graphs
   - Event routing between services
   - Distributed subscription management

---

## References

### GraphQL Specification
- [Section 6.2.3: Subscription Execution](https://spec.graphql.org/September2025/#sec-Subscription)
- [Section 5.2.4: Subscription Validation](https://spec.graphql.org/September2025/#sec-Single-root-field)

### Protocols
- [graphql-ws Protocol](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md)
- [graphql-transport-ws](https://github.com/enisdenjo/graphql-ws)
- [Server-Sent Events Spec](https://html.spec.whatwg.org/multipage/server-sent-events.html)

### Reference Implementations
- [GraphQL-JS Subscriptions](https://github.com/graphql/graphql-js/blob/main/src/subscription/subscribe.ts)
- [Apollo Server Subscriptions](https://www.apollographql.com/docs/apollo-server/data/subscriptions/)
- [graphql-ruby Subscriptions](https://graphql-ruby.org/subscriptions/overview.html)

### Crystal Resources
- [Crystal Concurrency](https://crystal-lang.org/reference/1.16/guides/concurrency.html)
- [Crystal WebSocket](https://crystal-lang.org/api/1.16.0/HTTP/WebSocket.html)
- [Crystal Channels](https://crystal-lang.org/api/1.16.0/Channel.html)

---

## Conclusion

Implementing GraphQL subscriptions in Oxide is a substantial but achievable undertaking. The plan outlined here provides a structured approach to building a spec-compliant, production-ready subscription system.

**Key Success Factors**:
1. Follow GraphQL spec closely for correctness
2. Prioritize thread safety and resource cleanup
3. Comprehensive testing at all layers
4. Clear documentation and examples
5. Performance monitoring and optimization

**Next Steps**:
1. Review and approve this plan
2. Allocate resources (developers, time)
3. Set up project tracking (milestones, sprints)
4. Begin Phase 1: Schema & Type System
5. Regular progress reviews and adjustments

With proper execution, Oxide will have robust subscription support that enables real-time GraphQL applications! 🚀
