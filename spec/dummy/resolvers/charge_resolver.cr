abstract class Loader

end

class Lazy(T)
  property source : Loader?
  property value : T | Nil

  def resolve(value)
    @value = value
  end

  def get
    pp "get"
    wait


    @value
  end

  def fulfill(value)
    @value = value
  end

  def wait
    if source
      source.not_nil!.wait
    end
  end
end

class RefundLoader < Loader
  @@loaders = {} of String => RefundLoader

  def self.for(model)
    @@loaders.fetch(model.name) do
      RefundLoader.new(model)
    end
  end

  def initialize(@model : Refund.class)
  end

  def load(key)
    if cache.has_key?(key.to_s)
      return cache[key.to_s]
    end

    queue << key.to_s

    promise = Lazy(Refund).new
    promise.source = self

    cache[key.to_s] = promise

    promise
  end

  def resolve
    load_keys = queue
    @queue = [] of String

    perform(load_keys)
  end

  def perform(ids)
    ids.each do |id|
      fulfill(id, Refund.new(id.to_i32, "pending", "re_refund", false))
    end
  end

  def fulfill(key, value)
    finish_resolve(key) do |promise|
      promise.fulfill(value)
    end
  end

  def finish_resolve(key)
    promise = promise_for(key)

    yield promise
  end

  def promise_for(key)
    cache[key]
  end

  def wait
    resolve
  end

  def cache
    @cache ||= {} of String => Lazy(Refund)
  end

  def queue
    @queue ||= [] of String
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  def resolve(object : Charge, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    when "reference"
      object.reference
    when "refund"
      RefundLoader.new(Refund).load(object.refund_id)
    end
  end
end
