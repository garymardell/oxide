require "./resolvable"

module Graphql
  class Schema
    abstract class Resolver
      include Resolvable
    end
  end
end
