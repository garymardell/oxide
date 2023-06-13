require "./argument"

module Oxide
  class Field
    getter type : Oxide::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Hash(String, Oxide::Argument)

    def initialize(@type, @description = nil, @deprecation_reason = nil, @arguments = {} of String => Oxide::Argument)
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
