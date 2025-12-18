require "../../spec_helper"

describe Oxide::Validation::OneOfInputObjects do
  it "allows exactly one field in OneOf input object" do
    # Create a OneOf input type
    oneof_input = Oxide::Types::InputObjectType.new(
      name: "OneOfInput",
      input_fields: {
        "a" => Oxide::Argument.new(type: Oxide::Types::StringType.new),
        "b" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
      },
      applied_directives: [
        Oxide::AppliedDirective.new(
          name: "oneOf",
          values: {} of String => JSON::Any
        )
      ]
    )
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            arguments: {
              "input" => Oxide::Argument.new(type: oneof_input)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "ok" }
          )
        }
      )
    )
    
    query_string = <<-QUERY
      {
        test(input: { a: "value" })
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      schema,
      query,
      [Oxide::Validation::OneOfInputObjects.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects OneOf input object with no fields" do
    oneof_input = Oxide::Types::InputObjectType.new(
      name: "OneOfInput",
      input_fields: {
        "a" => Oxide::Argument.new(type: Oxide::Types::StringType.new),
        "b" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
      },
      applied_directives: [
        Oxide::AppliedDirective.new(
          name: "oneOf",
          values: {} of String => JSON::Any
        )
      ]
    )
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            arguments: {
              "input" => Oxide::Argument.new(type: oneof_input)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "ok" }
          )
        }
      )
    )
    
    query_string = <<-QUERY
      {
        test(input: {})
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      schema,
      query,
      [Oxide::Validation::OneOfInputObjects.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/OneOfInput.*exactly one.*0/i)
  end

  it "rejects OneOf input object with multiple fields" do
    oneof_input = Oxide::Types::InputObjectType.new(
      name: "OneOfInput",
      input_fields: {
        "a" => Oxide::Argument.new(type: Oxide::Types::StringType.new),
        "b" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
      },
      applied_directives: [
        Oxide::AppliedDirective.new(
          name: "oneOf",
          values: {} of String => JSON::Any
        )
      ]
    )
    
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            arguments: {
              "input" => Oxide::Argument.new(type: oneof_input)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "ok" }
          )
        }
      )
    )
    
    query_string = <<-QUERY
      {
        test(input: { a: "value", b: 123 })
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      schema,
      query,
      [Oxide::Validation::OneOfInputObjects.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/OneOfInput.*exactly one.*2/i)
  end
end
