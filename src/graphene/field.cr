require "./argument"

module Graphene
  class Field
    getter name : String
    getter type : Graphene::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Array(Graphene::Argument)

    def initialize(@name, @type, @description = nil, @deprecation_reason = nil, @arguments = [] of Graphene::Argument)
    end

    def add_argument(argument : Graphene::Argument)
      @arguments << argument
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
