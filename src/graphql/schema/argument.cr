module Graphql
  class Schema
    class Argument
      alias DefaultValue = String | Int32 | Int64 | Float64 | Bool | Nil | Array(DefaultValue) | Hash(String, DefaultValue)

      getter name : String
      getter type : Graphql::Schema::Member
      getter default_value : DefaultValue
      getter? has_default_value : Bool

      def initialize(@name : String, @type : Graphql::Schema::Member)
        @default_value = nil
        @has_default_value = false
      end

      def initialize(@name : String, @type : Graphql::Schema::Member, @default_value : DefaultValue)
        @has_default_value = true
      end
    end
  end
end
