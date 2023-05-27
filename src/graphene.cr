module Graphene
  VERSION = "0.1.0"

  alias CoercedInput = String | Int32 | Int64 | Float32 | Float64 | Bool | Nil | Array(CoercedInput) | Hash(String, CoercedInput)
end

require "./graphene/schema"
require "./graphene/utils/**"