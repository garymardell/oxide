require "../spec_helper"

describe Graphql do
  it "executes" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }] })
  end

  it "supports dynamically generated schema" do
    fields = [
      "foo",
      "bar"
    ]

    query_type = Graphql::Type::Object.new(
      typename: "DynamicQuery",
      resolver: DynamicResolver.new,
      fields: fields.map do |field_name|
        Graphql::Schema::Field.new(
          name: field_name,
          type: Graphql::Type::String.new
        )
      end
    )

    schema = Graphql::Schema.new(query: query_type)

    query_string = <<-QUERY
      query {
        foo
        bar
      }
    QUERY

    runtime = Graphql::Execution::Runtime.new(
      schema,
      Graphql::Query.new(query_string)
    )

    result = runtime.execute

    result.should eq({ "foo" => "foo", "bar" => "bar" })
  end
end