require "../spec_helper"

class ContextTestContext < Oxide::Context
  property value : Int32 = 0
end

describe Oxide::Context do
  it "should progagate context to resolvers" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "increment" => Oxide::Field.new(
            type: Oxide::Types::BooleanType.new,
            resolve: ->(resolution : Oxide::Resolution(Nil)) {
              resolution.context.as(ContextTestContext).value += 1
              true
            }
          ),
          "decrement" => Oxide::Field.new(
            type: Oxide::Types::BooleanType.new,
            resolve: ->(resolution : Oxide::Resolution(Nil)) {
              resolution.context.as(ContextTestContext).value -= 1
              true
            }
          )
        }
      )
    )

    query = Oxide::Query.new(
      query_string: "{ firstIncrement: increment, secondIncrement: increment, firstDecrement: decrement }"
    )

    context = ContextTestContext.new

    runtime = Oxide::Execution::Runtime.new(schema)
    runtime.execute(query, context)

    context.value.should eq(1)
  end
end