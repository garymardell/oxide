module Graphql
  class Stream(T)
    def initialize(&callback : String? ->)
      @callback = callback
    end

    def emit(payload)
      if emitter = @on
        response = emitter.call(payload)
        @callback.call(response)
      end
    end

    def on(&on : T -> String?)
      @on = on
    end
  end
end