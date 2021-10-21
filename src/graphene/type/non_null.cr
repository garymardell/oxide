require "../type"

module Graphene
  class Type
    class NonNull < Type
      getter of_type : Graphene::Type

      def initialize(@of_type : Graphene::Type)
      end

      def kind
        "NON_NULL"
      end
    end
  end
end
