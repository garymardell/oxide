require "../../spec_helper"

describe Oxide::Language::Parser do
  it "supports directive definitions on SCHEMA" do
    schema = <<-QUERY
      directive @example on SCHEMA | Field

      schema @example {
        query: Query
      }
    QUERY

    document = Oxide::Language::Parser.parse(schema)

    definitions = document.definitions.select(type: Oxide::Language::Nodes::DirectiveDefinition)
    directive_definition = definitions.find(&.name.===("example"))
    directive_definition.should_not be_nil

    schema_definitions = document.definitions.select(type: Oxide::Language::Nodes::SchemaDefinition)
    schema_definition = schema_definitions.first
    schema_definition.should_not be_nil

    schema_directive = schema_definition.directives.find(&.name.===("example"))
    schema_directive.should_not be_nil
  end
end