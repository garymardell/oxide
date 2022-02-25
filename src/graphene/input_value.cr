module Graphene
  class InputValue
    alias DefaultValue = String | Int32 | Float32 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

    getter name : String
    getter type : Graphene::Type
    getter description : String?
    getter default_value : DefaultValue

    def initialize(@name, @type, @description = nil, @default_value = nil)
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
