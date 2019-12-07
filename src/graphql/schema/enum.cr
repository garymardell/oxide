require "./member"

module Graphql
  class Schema
    class Enum < Member
      property values : Array(String)

      def initialize(@values)
      end
    end
  end
end
