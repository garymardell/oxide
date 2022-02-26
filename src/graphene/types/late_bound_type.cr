require "../type"

module Graphene
  module Types
    class LateBoundType < Type
      getter typename : String

      def initialize(@typename)
      end

      def description
      end

      def coerce(value)
        raise "Invalid input type"
      end

      def serialize(value)
      end
    end
  end
end
