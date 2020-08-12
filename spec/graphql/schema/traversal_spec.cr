require "../../spec_helper"

describe Graphql::Schema::Traversal do
  it "collects all types" do
    traversal = Graphql::Schema::Traversal.new(DummySchema)
    traversal.traverse

    type_map = traversal.type_map
    type_map.keys.should eq(["Query", "Charge", "ID"])
  end
end