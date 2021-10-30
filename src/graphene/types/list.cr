require "../type"

module Graphene
  module Types
    class List < Type
      getter of_type : Graphene::Type

      def initialize(@of_type : Graphene::Type)
      end

      def kind
        "LIST"
      end

      def coerce(value)
        value
      end
    end
  end
end
