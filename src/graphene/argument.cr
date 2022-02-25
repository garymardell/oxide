module Graphene
  class Argument
    alias DefaultValue = String | Int32 | Float32 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

    getter name : String
    getter type : Graphene::Type
    getter default_value : DefaultValue
    getter? has_default_value : Bool

    def initialize(@name, @type)
      @default_value = nil
      @has_default_value = false
    end

    def initialize(@name, @type, @default_value)
      @has_default_value = true
    end
  end
end
