require "../../spec_helper"

describe Oxide::Execution::Response do
  it "serializes data without errors" do
    expected = "{\"data\":{\"post\":{\"id\":\"1234\"}}}"

    Oxide::Execution::Response.new(
      data: {
        "post" => {
          "id" => "1234".as(Oxide::SerializedOutput)
        }.as(Oxide::SerializedOutput)
      }.as(Oxide::SerializedOutput)
    ).to_json.should eq(expected)
  end

  it "serializes no data with errors" do
    expected = "{\"data\":null,\"errors\":[{\"message\":\"Error occurred\",\"locations\":[]}]}"

    Oxide::Execution::Response.new(
      errors: Set.new(
        [Oxide::Error.new("Error occurred")]
      )
    ).to_json.should eq(expected)
  end
end