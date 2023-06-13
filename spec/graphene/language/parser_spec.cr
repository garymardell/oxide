require "../../spec_helper"

describe Oxide::Language::Parser do
  it "supports object values" do
    schema = <<-QUERY
      query {
        fieldWithObject(object: { foo: "bar" }) {
          name
        }
      }
    QUERY

    parser = Oxide::Language::Parser.new

    document = parser.parse(schema)
  end

  it "supports list values" do
    schema = <<-QUERY
      query {
        fieldWithList(list: ["first", "second"]) {
          name
        }
      }
    QUERY

    parser = Oxide::Language::Parser.new

    document = parser.parse(schema)
  end
end