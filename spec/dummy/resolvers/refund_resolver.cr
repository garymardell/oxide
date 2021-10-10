class PaymentMethodLoader < Graphql::Loader(Int32, BankAccount | CreditCard | Nil)
  def perform(load_keys)
    load_keys.each do |key|
      fulfill(key, BankAccount.new(1, "1234578"))
    end
  end
end


class RefundResolver < Graphql::Schema::Resolver
  property loader : PaymentMethodLoader

  def initialize
    @loader = PaymentMethodLoader.new
  end

  def resolve(object : Refund, context, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    when "reference"
      object.reference
    when "partial"
      object.partial
    when "payment_method"
      loader.load(object.id)
    end
  end
end
