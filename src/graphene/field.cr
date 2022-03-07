require "./argument"

module Graphene
  class Field
    getter type : Graphene::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Hash(String, Graphene::Argument)

    def initialize(@type, @description = nil, @deprecation_reason = nil, @arguments = {} of String => Graphene::Argument)
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
