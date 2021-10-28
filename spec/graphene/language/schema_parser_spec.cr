require "../../spec_helper"

describe Graphene::Language::SchemaParser do
  it "supports directive definitions on SCHEMA" do
    schema = <<-QUERY
      directive @example on SCHEMA

      schema @example {
        query: Query
      }
    QUERY

    schema_parser = Graphene::Language::SchemaParser.new

    document = schema_parser.parse(schema)

    definitions = document.definitions.select(type: Graphene::Language::Nodes::DirectiveDefinition)
    directive_definition = definitions.find(&.name.===("example"))
    directive_definition.should_not be_nil

    schema_definitions = document.definitions.select(type: Graphene::Language::Nodes::SchemaDefinition)
    schema_definition = schema_definitions.first
    schema_definition.should_not be_nil

    schema_directive = schema_definition.directives.find(&.name.===("example"))
    schema_directive.should_not be_nil
  end
end