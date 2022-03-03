class BankAccountResolver < Graphene::Resolver
  def resolve(object : BankAccount, field_name, context, argument_values, resolution_info)
    case field_name
    when "id"
      object.id
    when "accountNumber"
      object.account_number
    end
  end
end
