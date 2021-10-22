require "../schema/type_resolver"
require "../type"

module Graphene
  class Type
    class Union < Type
      getter name : ::String
      getter possible_types : Array(Graphene::Type)

      def initialize(@name : ::String, @possible_types = [] of Graphene::Type)
      end

      def kind
        "UNION"
      end
    end
  end
end