module Oxide
  VERSION = "0.1.0"

  alias CoercedInput = String | Int32 | Int64 | Float32 | Float64 | Bool | Nil | Array(CoercedInput) | Hash(String, CoercedInput)
  alias SerializedOutput = String | Int32 | Float32 | Float64 | Bool | Nil | Array(SerializedOutput) | Hash(String, SerializedOutput)

  struct Resolution
    getter arguments : ArgumentValues
    getter execution_context : Execution::Context
    getter resolution_info : Execution::ResolutionInfo

    delegate schema, field, field_name, to: resolution_info
    delegate context, to: execution_context

    def initialize(@execution_context, @resolution_info, @arguments = {} of String => SerializedOutput)
    end
  end
end

require "./oxide/schema"
# require "./oxide/utils/**"