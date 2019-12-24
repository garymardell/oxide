require "../../spec_helper"

describe Graphql::Schema::Argument do
  describe "#new" do
    it "accepts name and type" do
      argument = Graphql::Schema::Argument.new("id", Graphql::Schema::IdType.new)

      argument.name.should eq("id")
      argument.type.should be_a(Graphql::Schema::IdType)
      argument.default_value.should be_nil
      argument.has_default_value?.should be_false
    end

    it "accepts name, type and default value" do
      argument = Graphql::Schema::Argument.new("id", Graphql::Schema::IdType.new, 123)

      argument.name.should eq("id")
      argument.type.should be_a(Graphql::Schema::IdType)
      argument.default_value.should eq(123)
      argument.has_default_value?.should be_true
    end
  end
end