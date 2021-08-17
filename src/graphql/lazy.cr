module Graphql
  class Lazy(T)
    property value : T | Nil
    property promise : Proc(T)

    def initialize(&blk : ->)
      @promise = blk
    end

    def fulfill(value : T)
      @value = value
    end

    def resolve
      @promise.call
    end
  end
end