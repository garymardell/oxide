module Graphql
  class Schema
    class Argument
      alias DefaultValue = String | Int32 | Int64 | Float64 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

      property name : String
      property type : Graphql::Schema::Member
      property default_value : DefaultValue
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
end
