require "benchmark"
require "./src/graphql-crystal"
require "./spec/dummy/schema"

query = Graphql::Language::Nodes::Document.new(
  definitions: [
    Graphql::Language::Nodes::OperationDefinition.new(
      operation_type: "query",
      selections: [
        Graphql::Language::Nodes::Field.new(
          name: "charge",
          arguments: [
            Graphql::Language::Nodes::Argument.new(
              name: "id",
              value: 12,
            )
          ],
          selections: [
            Graphql::Language::Nodes::Field.new(
              name: "id"
            ),
            Graphql::Language::Nodes::Field.new(
              name: "status"
            )
          ]
        ),
        Graphql::Language::Nodes::Field.new(
          name: "charges",
          selections: [
            Graphql::Language::Nodes::Field.new(
              name: "id"
            )
          ]
        )
      ]
    )
  ]
)

puts Benchmark.memory { 
  runtime = Graphql::Execution::Interpreter::Runtime.new(
    DummySchema,
    query
  )

  runtime.execute
}