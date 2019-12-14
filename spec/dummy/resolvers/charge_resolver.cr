class ChargeResolver < Graphql::Schema::Resolver
  def resolve(object : Charge, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    end
  end
end
