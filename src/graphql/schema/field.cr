module Graphql
  class Schema
    class Field
      property name : Symbol
      property null : Bool
      property description : String | Nil
      property deprecation_reason : String | Nil
      property arguments : Hash(Symbol, Graphql::Schema::Argument)

      def initialize(@name, @null, @description = nil, @deprecation_reason = nil)
        @arguments = {} of Symbol => Graphql::Schema::Argument
      end

      def add_argument(argument)
        @arguments[argument.name] = argument
      end
    end
  end
end
