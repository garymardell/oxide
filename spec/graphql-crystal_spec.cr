require "./spec_helper"

class Charge
  property id : Int32

  def initialize(@id)
  end
end

class QueryResolver < Graphql::Schema::Resolver
  def resolve(object, field_name)
    case field_name
    when "charge"
      Charge.new(id: 1)
    end
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  def resolve(object : Charge, field_name)
    case field_name
    when "id"
      object.id
    end
  end
end

describe Graphql do
  it "works" do
    schema = Graphql::Schema.new(
      query: Graphql::Schema::Object.new(
        resolver: QueryResolver.new,
        fields: [
          Graphql::Schema::Field.new(
            name: "charge",
            type: Graphql::Schema::Object.new(
              resolver: ChargeResolver.new,
              fields: [
                Graphql::Schema::Field.new(
                  name: "id",
                  type: Graphql::Schema::IdType.new,
                  null: false
                )
              ]
            ),
            null: false,
            arguments: [
              Graphql::Schema::Argument.new(
                name: "id"
              )
            ]
          )
        ]
      ),
      mutation: nil
    )

    if query = schema.query
      object = query.resolver.try &.resolve(nil, "charge")

      if field = query.get_field("charge")
        puts field.type.resolver.try &.resolve(object, "id")
      end
    end

  end
end
