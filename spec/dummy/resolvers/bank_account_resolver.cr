class BankAccountResolver < Graphene::Resolver
  def resolve(object : BankAccount, context, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "accountNumber"
      object.account_number
    end
  end
end
