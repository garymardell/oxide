class ReceiptResolver < Graphql::Schema::Resolver
  def resolve(object : Receipt, field_name, argument_values)
    case field_name
    when "id"
      object.id
    end
  end
end
