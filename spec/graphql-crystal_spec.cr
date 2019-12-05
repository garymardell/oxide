require "./spec_helper"

class Charge
  property id
end

describe Graphql do
  it "works" do
    schema = Graphql::Schema.new(
      query: Graphql::Schema::Object.new(
        fields: [
          Graphql::Schema::Field.new(
            name: :charge,
            null: false,
            arguments: [
              Graphql::Schema::Argument.new(
                name: :id
              )
            ]
          )
        ]
      )
    )
  end
end
