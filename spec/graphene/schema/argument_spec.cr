require "../../spec_helper"

describe Graphene::Argument do
  describe "#new" do
    it "accepts name and type" do
      argument = Graphene::Argument.new(Graphene::Types::IdType.new)

      argument.type.should be_a(Graphene::Types::IdType)
      argument.default_value.should be_nil
      argument.has_default_value?.should be_false
    end

    it "accepts name, type and default value" do
      argument = Graphene::Argument.new(Graphene::Types::IdType.new, 123)

      argument.type.should be_a(Graphene::Types::IdType)
      argument.default_value.should eq(123)
      argument.has_default_value?.should be_true
    end
  end
end