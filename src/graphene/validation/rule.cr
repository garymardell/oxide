require "./error"

module Graphene
  module Validation
    abstract class Rule
      property errors : Array(Error)

      def initialize
        @errors = [] of Error
      end

      def enter(node, context)
      end

      def leave(node, context)
      end
    end
  end
end