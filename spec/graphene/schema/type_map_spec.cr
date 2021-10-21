require "../../spec_helper"

describe Graphene::Schema::TypeMap do
  it "collects all types" do
    traversal = Graphene::Schema::TypeMap.new(DummySchema)
    type_map = traversal.generate

    type_map.keys.sort.should eq(["Query", "Charge", "ID", "CreditCard", "String", "BankAccount", "Refund", "Boolean"].sort)
  end
end