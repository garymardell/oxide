module Graphene
  class Argument
    alias DefaultValue = String | Int32 | Float32 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

    getter type : Graphene::Type
    getter description : String? = nil
    getter default_value : DefaultValue
    getter? has_default_value : Bool

    def initialize(@type)
      @default_value = nil
      @has_default_value = false
      @description = nil
    end

    def initialize(@type, @description)
      @default_value = nil
      @has_default_value = false
    end

    def initialize(@type, @default_value)
      @has_default_value = true
      @description = nil
    end

    def initialize(@type, @default_value, @description)
      @has_default_value = true
    end
  end
end
