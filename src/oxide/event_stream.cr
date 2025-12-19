module Oxide
  # EventStream is an abstraction over asynchronous event sources.
  # It provides a unified interface for subscription fields to emit events over time.
  # 
  # EventStream is based on Crystal's Iterator pattern but designed for async operations.
  # Implementations can wrap channels, fibers, external message queues, etc.
  abstract class EventStream(T)
    # Returns the next event from the stream, or nil if the stream has ended
    abstract def next : T?

    # Closes the stream and releases any resources
    abstract def close : Nil

    # Helper to iterate over all events until the stream ends
    def each(&block : T ->)
      while event = self.next
        yield event
      end
    ensure
      close
    end
  end

  # ChannelEventStream wraps a Crystal Channel as an event stream
  class ChannelEventStream(T) < EventStream(T)
    def initialize(@channel : Channel(T))
    end

    def next : T?
      @channel.receive?
    end

    def close : Nil
      @channel.close
    end
  end

  # ArrayEventStream is a simple event stream that emits values from an array
  # Useful for testing and simple use cases
  class ArrayEventStream(T) < EventStream(T)
    def initialize(@values : Array(T))
      @index = 0
    end

    def next : T?
      if @index < @values.size
        value = @values[@index]
        @index += 1
        value
      else
        nil
      end
    end

    def close : Nil
      # Nothing to clean up for array-based streams
    end
  end

  # EmptyEventStream represents a stream with no events
  class EmptyEventStream(T) < EventStream(T)
    def next : T?
      nil
    end

    def close : Nil
      # Nothing to clean up
    end
  end
end
