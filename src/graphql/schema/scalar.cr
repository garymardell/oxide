require "./member"

module Graphql
  class Schema
    abstract class Scalar < Member
    end

    class IdType < Scalar
    end
  end
end
