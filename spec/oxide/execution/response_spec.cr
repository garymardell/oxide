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
    expected = "{\"data\":null,\"errors\":[{\"message\":\"Error occurred\"}]}"

    Oxide::Execution::Response.new(
      errors: Set.new(
        [Oxide::RuntimeError.new("Error occurred")]
      )
    ).to_json.should eq(expected)
  end
  
  it "serializes errors with locations" do
    expected = "{\"data\":null,\"errors\":[{\"message\":\"Error occurred\",\"locations\":[{\"line\":1,\"column\":5}]}]}"

    Oxide::Execution::Response.new(
      errors: Set.new(
        [Oxide::RuntimeError.new("Error occurred", [Oxide::Location.new(1, 5)])]
      )
    ).to_json.should eq(expected)
  end
  
  it "serializes errors with path" do
    expected = "{\"data\":null,\"errors\":[{\"message\":\"Field error\",\"path\":[\"user\",\"posts\",0,\"title\"]}]}"

    Oxide::Execution::Response.new(
      errors: Set.new(
        [Oxide::RuntimeError.new("Field error", [] of Oxide::Location, ["user", "posts", 0, "title"] of (String | Int32))]
      )
    ).to_json.should eq(expected)
  end
  
  it "serializes errors with both locations and path" do
    expected = "{\"data\":null,\"errors\":[{\"message\":\"Field error\",\"locations\":[{\"line\":2,\"column\":10}],\"path\":[\"user\",\"email\"]}]}"

    Oxide::Execution::Response.new(
      errors: Set.new(
        [Oxide::RuntimeError.new("Field error", [Oxide::Location.new(2, 10)], ["user", "email"] of (String | Int32))]
      )
    ).to_json.should eq(expected)
  end
end