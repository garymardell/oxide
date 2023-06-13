module Oxide
  alias Result = Resolvable | String | Int16 | Int32 | Int64 | Int128 | Float32 | Float64 | Bool | Nil | Array(Result) | Array(Resolvable) | Array(Nil) | Execution::Lazy(Result)

  module Resolvable
    abstract def resolve(field_name, argument_values, context, resolution_info) : Result
  end
end