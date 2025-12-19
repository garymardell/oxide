require "http/web_socket"
require "json"

module Oxide
  module Transport
    # WebSocketHandler implements the graphql-ws protocol for GraphQL subscriptions over WebSocket.
    #
    # This handler manages the WebSocket connection lifecycle, message routing, and subscription
    # management for GraphQL subscriptions. It implements the graphql-ws protocol specification.
    #
    # ## Protocol
    # Supports the following message types:
    # - `connection_init`: Client initiates connection
    # - `connection_ack`: Server acknowledges connection
    # - `subscribe`: Client subscribes to a GraphQL operation
    # - `next`: Server sends a subscription event
    # - `error`: Server sends an error
    # - `complete`: Subscription completed (client or server initiated)
    # - `ping`/`pong`: Keep-alive messages
    #
    # ## Usage
    # ```
    # HTTP::WebSocket.new(context) do |socket|
    #   handler = Oxide::Transport::WebSocketHandler.new(socket, schema)
    #   handler.handle
    # end
    # ```
    #
    # ## Reference
    # Protocol specification: https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md
    class WebSocketHandler
      @subscriptions = {} of String => EventStream(Execution::Response)
      @socket : HTTP::WebSocket
      @schema : Schema
      @context : Context?
      
      def initialize(@socket : HTTP::WebSocket, @schema : Schema, @context : Context? = nil)
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
        send_error(ex.message || "Unknown error")
      end
      
      private def handle_connection_init(data)
        # Optional: Validate connection parameters from data["payload"]
        send_message({
          "type" => "connection_ack"
        })
      end
      
      private def handle_subscribe(data)
        id = data["id"].as_s
        payload = data["payload"]
        
        query_string = payload["query"].as_s
        variables = payload["variables"]?.try(&.as_h) || {} of String => JSON::Any
        operation_name = payload["operationName"]?.try(&.as_s)
        
        # Parse query
        query = Query.new(query_string)
        
        # Execute subscription
        runtime = Execution::Runtime.new(@schema)
        event_stream = runtime.execute_subscription(query, @context)
        
        # Store subscription
        @subscriptions[id] = event_stream
        
        # Subscribe to events in a fiber
        spawn do
          begin
            loop do
              response = event_stream.next
              break unless response
              
              send_message({
                "id" => id,
                "type" => "next",
                "payload" => response_to_json(response)
              })
            end
            
            # Send complete when stream ends
            send_message({
              "id" => id,
              "type" => "complete"
            })
          rescue IO::Error
            # Socket closed, clean up silently
          ensure
            @subscriptions.delete(id)
            event_stream.close
          end
        end
        
      rescue ex
        send_message({
          "id" => id,
          "type" => "error",
          "payload" => [{"message" => ex.message}]
        })
      end
      
      private def handle_complete(data)
        id = data["id"].as_s
        subscription = @subscriptions.delete(id)
        subscription.try(&.close)
      end
      
      private def handle_ping
        send_message({"type" => "pong"})
      end
      
      private def send_message(data)
        @socket.send(data.to_json)
      rescue IO::Error
        # Socket closed, ignore
      end
      
      private def send_error(message : String)
        send_message({
          "type" => "error",
          "payload" => [{"message" => message}]
        })
      end
      
      private def cleanup_subscriptions
        @subscriptions.each_value(&.close)
        @subscriptions.clear
      end
      
      private def response_to_json(response : Execution::Response)
        result = {} of String => JSON::Any
        
        if response.data
          result["data"] = JSON.parse(response.data.to_json)
        end
        
        errors = response.errors
        if errors && !errors.empty?
          error_list = errors.map do |error|
            JSON.parse(error.to_json)
          end
          result["errors"] = JSON.parse(error_list.to_json)
        end
        
        result
      end
    end
  end
end
