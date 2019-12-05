module Graphql
  class Schema
    abstract class Resolver
      abstract def resolve
    end
  end
end
