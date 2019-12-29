require "../type"

module Graphql
  class Type
    class NonNull < Type
      getter of_type : Graphql::Type

      def initialize(@of_type : Graphql::Type)
      end
    end
  end
end
