require "./subscribable"

module Graphql
  class Schema
    abstract class Subscriber
      include Subscribable
    end
  end
end
