class QueryResolver < Graphene::Resolver
  def resolve(object : Graphene::Resolvable?, field_name, argument_values, context, resolution_info) : Graphene::Result
    case field_name
    when "charge"
      # TODO: Had to add `to_s` as value comes bakc as int64 due to missing variable coercion
      Charge.new(id: argument_values["id"].to_s.to_i32, status: "pending", reference: "ch_1234").as(Graphene::Resolvable)
    when "charges"
      [
        Charge.new(id: 1, status: nil, reference: "ch_1234").as(Graphene::Resolvable),
        Charge.new(id: 2, status: "pending", reference: "ch_5678").as(Graphene::Resolvable),
        Charge.new(id: 3, status: nil, reference: "ch_5678").as(Graphene::Resolvable)
      ]
    when "transactions"
      [
        Charge.new(id: 1, status: "paid", reference: "ch_1234").as(Graphene::Resolvable),
        Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true).as(Graphene::Resolvable)
      ]
    when "paymentMethods"
      [
        CreditCard.new(id: 1, last4: "4242").as(Graphene::Resolvable),
        BankAccount.new(id: 32, account_number: "1234567").as(Graphene::Resolvable)
      ]
    when "nullList"
      [nil]
    end
  end

  def resolve(object, field_name, argument_values, context, resolution_info)
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