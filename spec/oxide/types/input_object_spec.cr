require "../../spec_helper"

describe Oxide::Types::InputObjectType do
  describe "#coerce" do
    it "it coerces a json hash" do
      input_object = Oxide::Types::InputObjectType.new(
        name: "Test",
        input_fields: {
          "id" => Oxide::Argument.new(
            type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::IdType.new
            ),
          )
        }
      )

      object = input_object.coerce(DummySchema, { "id" => JSON::Any.new("1") })
      object.should eq({ "id" => "1" })
    end

    it "it coerces nested input types" do
      model_input_object = Oxide::Types::InputObjectType.new(
        name: "ModelInput",
        input_fields: {
          "id" => Oxide::Argument.new(
            type: Oxide::Types::NonNullType.new(
              of_type: Oxide::Types::IdType.new
            ),
          )
        }
      )

      input_object = Oxide::Types::InputObjectType.new(
        name: "Test",
        input_fields: {
          "input" => Oxide::Argument.new(
            type: Oxide::Types::NonNullType.new(
              of_type: model_input_object
            ),
          )
        }
      )

      object = input_object.coerce(DummySchema, { "input" => JSON::Any.new({ "id" => JSON::Any.new("1") }) })
      object.should eq({"input" => { "id" => "1" }})
    end
  end
end