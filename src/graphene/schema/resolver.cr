require "./resolvable"

module Graphene
  class Schema
    abstract class Resolver
      include Resolvable
    end
  end
end
