class CreditCardResolver < Graphql::Schema::Resolver
  def resolve(object : CreditCard, context, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "last4"
      object.last4
    end
  end
end
