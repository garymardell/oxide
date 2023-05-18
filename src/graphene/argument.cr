module Graphene
  class Argument
    include Resolvable

    alias DefaultValue = String | Int32 | Float32 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

    getter type : Graphene::Type
    getter default_value : DefaultValue
    getter? has_default_value : Bool

    def initialize(@type)
      @default_value = nil
      @has_default_value = false
    end

    def initialize(@type, @default_value)
      @has_default_value = true
    end

    def resolve(field_name, argument_values, context, resolution_info) : Result
      case field_name
      when "type"
        type
      end
    end
  end
end
