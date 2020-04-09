module Graphql
  class Schema
    class PossibleTypes
      def initialize(@schema)
      end

      def possible_types(type)
        case type
        when Graphql::Type
          [type]
        end
      end
    end
  end
end