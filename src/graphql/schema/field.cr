module Graphql
  class Schema
    class Field
      property name : Symbol
      property type : Graphql::Schema::Member
      property null : Bool
      property description : String | Nil
      property deprecation_reason : String | Nil
      property arguments : Array(Graphql::Schema::Argument)

      def initialize(@name, @type, @null, @description = nil, @deprecation_reason = nil, @arguments = [] of Graphql::Schema::Argument)
      end

      def add_argument(argument)
        @arguments << argument
      end

      def self.default_resolver
        @@default_resolver ||= DefaultResolver.new
      end
    end
  end
end
