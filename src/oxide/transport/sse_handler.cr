require "http/server"
require "json"

module Oxide
  module Transport
    # SSEHandler implements GraphQL subscriptions over Server-Sent Events (SSE).
    #
    # This is a simpler alternative to WebSocket for server-to-client streaming.
    # SSE uses a regular HTTP connection with Content-Type: text/event-stream.
    #
    # ## Features
    # - Simple HTTP-based protocol
    # - Automatic reconnection support in browsers
    # - Works through most proxies and firewalls
    # - Server-to-client only (no client-to-server messages)
    #
    # ## Limitations
    # - No bidirectional communication (use WebSocket for that)
    # - No per-connection authentication after initial request
    # - Some older browsers don't support EventSource
    #
    # ## Usage
    # ```
    # server = HTTP::Server.new do |context|
    #   query = Oxide::Query.new(params["query"])
    #   Oxide::Transport::SSEHandler.handle(context, schema, query)
    # end
    # ```
    #
    # ## Client Example (JavaScript)
    # ```javascript
    # const es = new EventSource('/graphql/subscribe?query=subscription { ... }');
    # es.addEventListener('next', (event) => {
    #   const data = JSON.parse(event.data);
    #   console.log(data);
    # });
    # ```
    class SSEHandler
      def self.handle(
        http_context : HTTP::Server::Context,
        schema : Schema,
        query : Query,
        context : Context? = nil
      )
        http_context.response.content_type = "text/event-stream"
        http_context.response.headers["Cache-Control"] = "no-cache"
        http_context.response.headers["Connection"] = "keep-alive"
        http_context.response.headers["X-Accel-Buffering"] = "no" # Disable nginx buffering
        
        # Execute subscription
        runtime = Execution::Runtime.new(schema)
        event_stream = runtime.execute_subscription(query, context)
        
        # Stream events
        loop do
          response = event_stream.next
          break unless response
          
          write_sse_event(http_context.response, response)
        end
        
      rescue ex
        write_sse_error(http_context.response, ex.message || "Unknown error")
      ensure
        event_stream.try(&.close)
      end
      
      private def self.write_sse_event(response : HTTP::Server::Response, data : Execution::Response)
        response << "event: next\n"
        response << "data: #{response_to_json(data).to_json}\n\n"
        response.flush
      end
      
      private def self.write_sse_error(response : HTTP::Server::Response, message : String)
        response << "event: error\n"
        response << "data: #{{"message" => message}.to_json}\n\n"
        response.flush
      end
      
      private def self.response_to_json(response : Execution::Response)
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
