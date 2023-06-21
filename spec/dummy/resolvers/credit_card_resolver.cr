class CreditCardResolver
  include Oxide::Resolves(CreditCard)

  def resolve(object : CreditCard, field_name, argument_values, context, resolution_info)
    case field_name
    when "id"
      object.id
    when "last4"
      object.last4
    end
  end
end
