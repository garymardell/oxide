require "../../spec_helper"

describe Graphql::Schema::TypeMap do
  it "collects all types" do
    traversal = Graphql::Schema::TypeMap.new(DummySchema)
    type_map = traversal.generate

    type_map.keys.sort.should eq(["Query", "Charge", "ID", "CreditCard", "String", "BankAccount", "Receipt", "Refund", "Boolean"].sort)
  end
end