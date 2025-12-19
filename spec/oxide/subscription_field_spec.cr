require "../spec_helper"

describe Oxide::SubscriptionField do
  it "creates a subscription field with subscribe and resolve procs" do
    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::StringType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        Oxide::ArrayEventStream.new([{"value" => "event1"}, {"value" => "event2"}])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) {
        event
      }
    )

    field.type.should be_a(Oxide::Types::StringType)
    field.description.should be_nil
    field.deprecation_reason.should be_nil
  end

  it "supports description and deprecation" do
    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::IntType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        Oxide::EmptyEventStream(Hash(String, String)).new
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event },
      description: "A subscription field",
      deprecation_reason: "Use v2 instead"
    )

    field.description.should eq("A subscription field")
    field.deprecation_reason.should eq("Use v2 instead")
    field.deprecated?.should be_true
  end

  it "subscribe returns an event stream" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      )
    )

    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::StringType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        Oxide::ArrayEventStream.new([{"val" => "a"}, {"val" => "b"}, {"val" => "c"}])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event }
    )

    query = Oxide::Query.new("{ test }")
    context = Oxide::Execution::Context.new(schema, query)
    resolution_info = Oxide::Execution::ResolutionInfo.new(
      schema: schema,
      context: context,
      field: field.as(Oxide::BaseField),
      field_name: "test"
    )

    stream = field.subscribe(nil, {} of String => JSON::Any, context, resolution_info)
    
    stream.should be_a(Oxide::EventStream(Hash(String, String)))
    stream.next.should eq({"val" => "a"})
    stream.next.should eq({"val" => "b"})
    stream.next.should eq({"val" => "c"})
    stream.next.should be_nil
  end

  it "resolve transforms events to output values" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      )
    )

    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::IntType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        Oxide::ArrayEventStream.new([{"num" => "5"}])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event }
    )

    query = Oxide::Query.new("{ test }")
    context = Oxide::Execution::Context.new(schema, query)
    resolution_info = Oxide::Execution::ResolutionInfo.new(
      schema: schema,
      context: context,
      field: field.as(Oxide::BaseField),
      field_name: "test"
    )

    result = field.resolve({"num" => "5"}, {} of String => JSON::Any, context, resolution_info)
    result.should eq({"num" => "5"})
  end

  it "supports arguments" do
    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::StringType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        topic = resolution.arguments["topic"].as_s
        Oxide::ArrayEventStream.new([{"topic" => "#{topic}:1"}, {"topic" => "#{topic}:2"}])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event },
      arguments: {
        "topic" => Oxide::Argument.new(
          type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new)
        )
      }
    )

    field.arguments.size.should eq(1)
    field.arguments["topic"].should be_a(Oxide::Argument)
  end

  it "raises error if subscribe object type doesn't match" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      )
    )

    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::StringType.new,
      subscribe: ->(object : Hash(String, String), resolution : Oxide::Resolution) {
        Oxide::ArrayEventStream.new([object])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event["val"] }
    )

    query = Oxide::Query.new("{ test }")
    context = Oxide::Execution::Context.new(schema, query)
    resolution_info = Oxide::Execution::ResolutionInfo.new(
      schema: schema,
      context: context,
      field: field.as(Oxide::BaseField),
      field_name: "test"
    )

    expect_raises(Oxide::SchemaError, "Expected object to be Hash(String, String) but received Nil") do
      field.subscribe(nil, {} of String => JSON::Any, context, resolution_info)
    end
  end

  it "raises error if resolve event type doesn't match" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      )
    )

    field = Oxide::SubscriptionField.new(
      type: Oxide::Types::IntType.new,
      subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
        Oxide::ArrayEventStream.new([{"val" => "1"}, {"val" => "2"}, {"val" => "3"}])
      },
      resolve: ->(event : Hash(String, String), resolution : Oxide::Resolution) { event["val"].to_i }
    )

    query = Oxide::Query.new("{ test }")
    context = Oxide::Execution::Context.new(schema, query)
    resolution_info = Oxide::Execution::ResolutionInfo.new(
      schema: schema,
      context: context,
      field: field.as(Oxide::BaseField),
      field_name: "test"
    )

    expect_raises(Oxide::SchemaError, "Expected event to be Hash(String, String) but received Nil") do
      field.resolve(nil, {} of String => JSON::Any, context, resolution_info)
    end
  end
end
