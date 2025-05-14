require "../../spec_helper"

describe Oxide::Language::Printer do
  it "prints the query to an IO instance" do
    input = <<-INPUT
    query ($a: Int!, $b: Int!) {
      thing (a: $a) {
        id
      }
    }
    INPUT

    query = Oxide::Query.new(input)

    output = String.build do |io|
      query.print(io)
    end

    output.strip.should eq(input.strip)
  end
end