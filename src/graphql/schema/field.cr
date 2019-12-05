module Graphql
  class Schema
    class Field
      property name : Symbol
      property null : Bool
      property description : String | Nil
      property deprecation_reason : String | Nil
      property arguments : Array(Graphql::Schema::Argument)

      def initialize(@name, @null, @description = nil, @deprecation_reason = nil, @arguments = [] of Graphql::Schema::Argument)
      end

      def add_argument(argument)
        @arguments << argument
      end
    end
  end
end
