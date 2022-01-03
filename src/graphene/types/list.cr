require "../type"

module Graphene
  module Types
    class List < Type
      getter description : ::String?
      getter of_type : Graphene::Type

      def initialize(@of_type, @description = nil)
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
