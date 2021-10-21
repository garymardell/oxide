require "../type"

module Graphene
  class Type
    class List < Type
      getter of_type : Graphene::Type

      def initialize(@of_type : Graphene::Type)
      end

      def kind
        "LIST"
      end
    end
  end
end
