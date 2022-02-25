require "../../spec_helper"

describe Graphene::Language::Parser do
  it "supports object values" do
    schema = <<-QUERY
      query {
        fieldWithObject(object: { foo: "bar" }) {
          name
        }
      }
    QUERY

    parser = Graphene::Language::Parser.new

    document = parser.parse(schema)

    pp document

  end

  it "supports list values" do
    schema = <<-QUERY
      query {
        fieldWithList(list: ["first", "second"]) {
          name
        }
      }
    QUERY

    parser = Graphene::Language::Parser.new

    document = parser.parse(schema)

    pp document

  end
end