require "benchmark"
require "json"

require "../src/oxide"

query_string = <<-QUERY
  query {
    charges {
      id
      status
    }
  }
QUERY

query_json = JSON.build do |json|
  json.object do
    json.field "query", query_string
  end
end


# performance  89.87k ( 11.13µs) (± 0.40%)  4.27kB/op  fastest
Benchmark.ips do |x|
  x.report("query") {
    query = Oxide::Query.from_json(query_json)
    query.operation_name # Called to prevent being optimized out
  }
end