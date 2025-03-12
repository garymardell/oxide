require "../../spec_helper"

describe Oxide::Language::Nodes do
  describe Oxide::Language::Nodes::Type do
    it "converts to string representation" do
      Oxide::Language::Nodes::NamedType.new("User").to_s.should eq ("User")

      Oxide::Language::Nodes::NonNullType.new(
        Oxide::Language::Nodes::NamedType.new("User")
      ).to_s.should eq("User!")

      Oxide::Language::Nodes::ListType.new(
        Oxide::Language::Nodes::NamedType.new("User")
      ).to_s.should eq("[User]")

      Oxide::Language::Nodes::NonNullType.new(
        Oxide::Language::Nodes::ListType.new(
          Oxide::Language::Nodes::NonNullType.new(Oxide::Language::Nodes::NamedType.new("User"))
        )
      ).to_s.should eq("[User!]!")
    end
  end
end