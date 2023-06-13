class Query
  include Oxide::Resolvable

  def resolve(field_name, argument_values, context, resolution_info) : Oxide::Result
    case field_name
    when "createCharge"
      input = argument_values["input"]

      reference = if input.is_a?(Hash)
        input["reference"].to_s
      else
        raise "Reference was not in the input"
      end

      Charge.new(id: 34353, status: "pending", reference: reference).as(Oxide::Resolvable)
    when "charge"
      # TODO: Had to add `to_s` as value comes bakc as int64 due to missing variable coercion
      Charge.new(id: argument_values["id"].to_s.to_i32, status: "pending", reference: "ch_1234").as(Oxide::Resolvable)
    when "charges"
      [
        Charge.new(id: 1, status: nil, reference: "ch_1234").as(Oxide::Resolvable),
        Charge.new(id: 2, status: "pending", reference: "ch_5678").as(Oxide::Resolvable),
        Charge.new(id: 3, status: nil, reference: "ch_5678").as(Oxide::Resolvable)
      ]
    when "transactions"
      [
        Charge.new(id: 1, status: "paid", reference: "ch_1234").as(Oxide::Resolvable),
        Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true).as(Oxide::Resolvable)
      ]
    when "paymentMethods"
      [
        CreditCard.new(id: 1, last4: "4242").as(Oxide::Resolvable),
        BankAccount.new(id: 32, account_number: "1234567").as(Oxide::Resolvable)
      ]
    when "nullList"
      [nil]
    end
  end
end