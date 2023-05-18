class BankAccount
  include Graphene::Resolvable

  property id : Int32
  property account_number : String

  def initialize(@id, @account_number)
  end

  def resolve(field_name, argument_values, context, resolution_info) : Graphene::Result
    case field_name
    when "id"
      id
    when "accountNumber"
      account_number
    end
  end
end