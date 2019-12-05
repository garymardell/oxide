module Graphql
  class Schema
    abstract class Scalar < Member
    end

    class IdType < Scalar
      def initialize
        @resolver = ScalarResolver.new
      end
    end
  end
end
