class BankAccountResolver
  include Oxide::Resolves(BankAccount)

  def resolve(object : BankAccount, field_name, argument_values, context, resolution_info)
    case field_name
    when "id"
      object.id
    when "accountNumber"
      object.account_number
    end
  end
end
