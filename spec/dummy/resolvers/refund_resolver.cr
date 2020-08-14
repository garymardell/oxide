class RefundResolver < Graphql::Schema::Resolver
  def resolve(object : Refund, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    when "partial"
      object.partial
    end
  end
end
