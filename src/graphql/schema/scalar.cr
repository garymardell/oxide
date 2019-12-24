require "./member"

module Graphql
  class Schema
    abstract class Scalar < Member
    end

    class Id < Scalar
    end
  end
end
