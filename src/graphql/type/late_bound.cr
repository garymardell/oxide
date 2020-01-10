require "../type"

module Graphql
  class Type
    class LateBound < Type
      getter typename : ::String

      def initialize(@typename : ::String)
      end
    end
  end
end
