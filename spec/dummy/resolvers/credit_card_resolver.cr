class CreditCardResolver < Graphene::Resolver
  def resolve(object : Graphene::Resolvable?, field_name, argument_values, context, resolution_info) : Graphene::Result
  end

  def resolve(object : CreditCard, field_name, argument_values, context, resolution_info)
    case field_name
    when "id"
      object.id
    when "last4"
      object.last4
    end
  end
end
