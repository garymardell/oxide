require "../type"

module Graphene
  class Type
    class InputObject < Type
      getter name : ::String

      def initialize(@name : ::String)
      end

      def kind
        "INPUT_OBJECT"
      end
    end
  end
end
