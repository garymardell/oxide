require "../type"

module Graphene
  module Types
    class LateBound < Type
      getter typename : ::String

      def initialize(@typename)
      end

      def description
      end

      def coerce(value)
        raise "Invalid input type"
      end
    end
  end
end
