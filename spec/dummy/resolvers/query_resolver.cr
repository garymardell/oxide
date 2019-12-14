class QueryResolver < Graphql::Schema::Resolver
  def resolve(object, field_name, argument_values)
    case field_name
    when "charge"
      Promise.defer {
        Charge.new(id: argument_values["id"].as(Int32), status: "pending")
      }
    when "charges"
      [
        Charge.new(id: 1, status: "paid"),
        Charge.new(id: 2, status: "pending")
      ]
    end
  end
end