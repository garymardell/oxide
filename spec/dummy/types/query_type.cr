module Types
  class QueryType < Graphql::DSL::Object
    field "charge", Types::ChargeType, null: false do
      argument "id", type: Graphql::DSL::Id, required: true
    end

    field "charges", Graphql::DSL::NonNull.new(Graphql::DSL::List.new(Types::ChargeType)), null: false

    def resolve(object, field_name, argument_values)
      case field_name
      when "charge"
        Charge.new(id: argument_values["id"].as(Int32), status: "pending")
      when "charges"
        [
          Charge.new(id: 1, status: "paid"),
          Charge.new(id: 2, status: "pending")
        ]
      end
    end
  end
end