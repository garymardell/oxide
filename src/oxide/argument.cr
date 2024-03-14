module Oxide
  class Argument
    alias DefaultValue = String | Int32 | Float32 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

    getter type : Oxide::Type
    getter description : String? = nil
    getter default_value : DefaultValue
    getter? has_default_value : Bool
    property applied_directives : Array(Directive) = [] of Directive

    def initialize(@type : Oxide::Type, @applied_directives : Array(Directive) = [] of Directive)
      @default_value = nil
      @has_default_value = false
      @description = nil
    end

    def initialize(@type : Oxide::Type, @description, @applied_directives : Array(Directive) = [] of Directive)
      @default_value = nil
      @has_default_value = false
    end

    def initialize(@type, @default_value, @applied_directives : Array(Directive) = [] of Directive)
      @has_default_value = true
      @description = nil
    end

    def initialize(@type, @default_value, @description, @applied_directives : Array(Directive) = [] of Directive)
      @has_default_value = true
    end
  end
end
