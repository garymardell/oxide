module Graphql
  class Schema
    abstract class Member
      property resolver : Resolver | Nil
    end
  end
end
