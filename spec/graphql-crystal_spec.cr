require "./spec_helper"

class Charge
  property id : Int32

  def initialize(@id)
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  def resolve
    Charge.new(id: 1)
  end
end

describe Graphql do
  it "works" do
    field = Graphql::Schema::Field.new(
      name: :charge,
      null: false,
      arguments: [
        Graphql::Schema::Argument.new(
          name: :id
        )
      ],
      resolver: ChargeResolver.new
    )

    object = Graphql::Schema::Object.new(
      fields: [
        field
      ]
    )

    schema = Graphql::Schema.new(
      query: object,
      mutation: nil
    )

    if query = schema.query
      if field = query.get_field(:charge)
        puts field.resolver
        puts field.resolver.resolve()
      end
    end

  end
end
