class BankAccountResolver < Graphql::Schema::Resolver
  def resolve(object : BankAccount, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "accountNumber"
      object.account_number
    end
  end
end
