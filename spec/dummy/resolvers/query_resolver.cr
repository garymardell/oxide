class QueryResolver < Graphql::Schema::Resolver
  def resolve(object, field_name, argument_values)
    case field_name
    when "charge"
      # TODO: Had to add `to_s` as value comes bakc as int64 due to missing variable coercion
      Charge.new(id: argument_values["id"].to_s.to_i32, status: "pending")
    when "charges"
      [
        Charge.new(id: 1, status: "paid"),
        Charge.new(id: 2, status: "pending")
      ]
    end
  end
end