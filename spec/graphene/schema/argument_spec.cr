require "../../spec_helper"

describe Graphene::Schema::Argument do
  describe "#new" do
    it "accepts name and type" do
      argument = Graphene::Schema::Argument.new("id", Graphene::Types::Id.new)

      argument.name.should eq("id")
      argument.type.should be_a(Graphene::Types::Id)
      argument.default_value.should be_nil
      argument.has_default_value?.should be_false
    end

    it "accepts name, type and default value" do
      argument = Graphene::Schema::Argument.new("id", Graphene::Types::Id.new, 123)

      argument.name.should eq("id")
      argument.type.should be_a(Graphene::Types::Id)
      argument.default_value.should eq(123)
      argument.has_default_value?.should be_true
    end
  end
end