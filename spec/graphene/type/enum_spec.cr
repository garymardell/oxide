require "../../spec_helper"

def build_enum_value(name = "paid", description = "Item is paid", value = nil, deprecation_reason = nil)
  Graphene::Type::EnumValue.new(
    name: name,
    description: description,
    value: value,
    deprecation_reason: deprecation_reason
  )
end

describe Graphene::Type::Enum do
  describe "#new" do
    it "accepts an array of EnumValues" do
      values = [build_enum_value]

      e = Graphene::Type::Enum.new(
        name: "Test",
        values: values
      )

      e.values.should eq(values)
    end
  end

  describe Graphene::Type::EnumValue do
    describe "#new" do
      it "defaults value to name if not specified" do
        enum_value = build_enum_value(name: "paid", value: nil)

        enum_value.value.should eq("paid")
      end
    end
  end
end