module Graphql
  class Schema
    abstract class Member
      getter resolver : Resolver?
    end
  end
end
