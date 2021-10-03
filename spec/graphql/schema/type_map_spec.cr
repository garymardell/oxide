require "../../spec_helper"

describe Graphql::Schema::TypeMap do
  it "collects all types" do
    traversal = Graphql::Schema::TypeMap.new(DummySchema.compile)
    type_map = traversal.generate

    type_map.keys.sort.should eq(["Query", "Charge", "ID", "CreditCard", "String", "BankAccount", "Refund", "Boolean"].sort)
  end
end