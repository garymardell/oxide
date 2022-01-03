module Graphene
  class Schema
    class Field
      getter name : String
      getter type : Graphene::Type
      getter description : String?
      getter deprecation_reason : String?
      getter arguments : Array(Graphene::Schema::Argument)

      def initialize(@name : String, @type : Graphene::Type, @description : String? = nil, @deprecation_reason : String? = nil, @arguments = [] of Graphene::Schema::Argument)
      end

      def add_argument(argument : Graphene::Schema::Argument)
        @arguments << argument
      end

      def deprecated?
        !deprecation_reason.nil?
      end
    end
  end
end
