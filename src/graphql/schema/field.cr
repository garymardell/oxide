module Graphql
  class Schema
    class Field
      getter name : String
      getter type : Graphql::Schema::Member
      getter description : String?
      getter deprecation_reason : String?
      getter arguments : Array(Graphql::Schema::Argument)

      def initialize(@name : String, @type : Graphql::Schema::Member, @description : String? = nil, @deprecation_reason : String? = nil, @arguments = [] of Graphql::Schema::Argument)
      end

      def add_argument(argument : Graphql::Schema::Argument)
        @arguments << argument
      end
    end
  end
end
