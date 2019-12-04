require "./spec_helper"

class Charge
  property id
end

class ChargeType < Graphql::Schema::Object
  field :id, Graphql::Types::IDType, null: false, description: "Identifier"
end

class QueryType < Graphql::Schema::Object
  field :charge, ChargeType, null: false, description: "Example charge"
end

class MySchema < Graphql::Schema
  query QueryType
end

describe Graphql do
  # TODO: Write tests

  it "works" do
    # Ch
  end
end
