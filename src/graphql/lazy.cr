module Graphql
  class Lazy(T)
    property value : T | Nil
    property promise : Proc(T)

    def initialize(&blk : -> T)
      @promise = blk
    end

    def wrap(&blk : -> Graphql::Execution::Runtime::ReturnType)
      @wrapper = blk
    end

    def unwrap
      if callback = @wrapper
        callback.call
      end
    end

    def resolve
      @value = @promise.call
    end

    def on_resolve(&blk : ->)
      @on_resolve = blk
    end
  end
end