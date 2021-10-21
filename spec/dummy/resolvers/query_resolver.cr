class QueryResolver < Graphene::Schema::Resolver
  def resolve(object, context, field_name, argument_values)
    case field_name
    when "charge"
      # TODO: Had to add `to_s` as value comes bakc as int64 due to missing variable coercion
      Charge.new(id: argument_values["id"].to_s.to_i32, status: "pending", reference: "ch_1234")
    when "charges"
      [
        Charge.new(id: 1, status: nil, reference: "ch_1234"),
        Charge.new(id: 2, status: "pending", reference: "ch_5678"),
        Charge.new(id: 3, status: nil, reference: "ch_5678")
      ]
    when "transactions"
      [
        Charge.new(id: 1, status: "paid", reference: "ch_1234"),
        Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true)
      ]
    when "paymentMethods"
      [
        CreditCard.new(id: 1, last4: "4242"),
        BankAccount.new(id: 32, account_number: "1234567")
      ]
    when "nullList"
      [nil]
    end
  end
end