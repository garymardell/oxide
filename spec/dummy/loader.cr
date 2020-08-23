require "promise"

class Lazy(T, K)
  property loader : Loader(T, K)
  property promise : Promise::DeferredPromise(T | Nil)

  def initialize(loader)
    @loader = loader
    @promise = Promise::DeferredPromise(T | Nil).new
  end

  def resolve(value)
    promise.resolve(value)
  end

  def wait
    loader.resolve

    promise.get
  end
end

abstract class Loader(T, K)
  property cache : Hash(K, Lazy(T, K))
  property queue : Array(K)

  def initialize
    @cache = {} of K => Lazy(T, K)
    @queue = [] of K
  end

  def load(key)
    @cache[key] ||= begin
      @queue << key

      # Promise::DeferredPromise(T | Nil).new
      Lazy(T, K).new(self)
    end
  end

  def resolve
    return if resolved?

    load_keys = @queue

    @queue = [] of K

    perform(load_keys)
  end

  def resolved?
    @queue.empty?
  end

  def perform(keys)
    raise "Implement perform"
  end

  def fulfill(key, value)
    finish_resolve(key) do |lazy|
      lazy.resolve(value)
    end
  end

  def lazy_for(key)
    cache[key]
  end

  def finish_resolve(key)
    lazy = lazy_for(key)

    yield lazy
  end
end
