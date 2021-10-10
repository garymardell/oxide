require "../../src/graphql"
require "./models/*"
require "./resolvers/*"

class BankAccountType < Graphql::DSL::Object
  graphql_name "BankAccount"

  field :id, Graphql::DSL::Id, null: true
  field :accountNumber, Graphql::DSL::String, null: true

  def accountNumber(object : BankAccount, argument_values)
    object.account_number
  end
end

class CreditCardType < Graphql::DSL::Object
  graphql_name "CreditCard"

  field :id, Graphql::DSL::Id, null: true
  field :last4, Graphql::DSL::String, null: true
end

class PaymentMethodType < Graphql::DSL::Union
  graphql_name "PaymentMethod"

  possible_types CreditCardType, BankAccountType

  def self.resolve_type(object, context)
    case object
    when CreditCard
      CreditCardType
    when BankAccount
      BankAccountType
    end
  end
end

class TransactionInterface < Graphql::DSL::Interface
  field :id, Graphql::DSL::Id, null: false
  field :reference, Graphql::DSL::String, null: false

  def self.resolve_type(object, context)
    case object
    when Charge
      ChargeType
    when Refund
      RefundType
    end
  end
end

class ChargeStatus < Graphql::DSL::Enum
  value "PENDING", value: "pending"
  value "PAID", value: "paid"
end

class RefundLoader < Graphql::Loader(Int32, Refund?)
  def perform(load_keys)
    load_keys.each do |key|
      fulfill(key, Refund.new(key, "pending", "r_12345", false))
    end
  end
end

class ChargeType < Graphql::DSL::Object
  graphql_name "Charge"

  implements TransactionInterface

  field :status, ChargeStatus, null: false

  field :refund, RefundType, null: true

  def initialize
    @loader = RefundLoader.new
  end

  def refund(object : Charge, argument_values)
    @loader.load(object.id)
  end
end

class RefundStatus < Graphql::DSL::Enum
  value "PENDING", value: "pending"
  value "REFUNDED", value: "refunded"
end

class PaymentMethodLoader < Graphql::Loader(Int32, BankAccount | CreditCard | Nil)
  def perform(load_keys)
    load_keys.each do |key|
      fulfill(key, BankAccount.new(1, "1234578"))
    end
  end
end

class RefundType < Graphql::DSL::Object
  graphql_name "Refund"

  implements TransactionInterface

  field :status, RefundStatus, null: true

  field :partial, Graphql::DSL::Boolean, null: true

  field :payment_method, PaymentMethodType, null: true

  property loader : PaymentMethodLoader

  def initialize
    @loader = PaymentMethodLoader.new
  end

  def payment_method(object : Refund, argument_values)
    @loader.load(object.id)
  end
end


class QueryType < Graphql::DSL::Object
  graphql_name "Query"

  field :charge, ChargeType, null: true do
    argument :id, Graphql::DSL::Id, required: true
  end

  def charge(object, argument_values)
    Charge.new(id: argument_values["id"].to_s.to_i32, status: "pending", reference: "ch_1234")
  end


  field :charges, [ChargeType], null: false

  def charges(object, argument_values)
    [
      Charge.new(id: 1, status: nil, reference: "ch_1234"),
      Charge.new(id: 2, status: "pending", reference: "ch_5678"),
      Charge.new(id: 3, status: nil, reference: "ch_5678")
    ]
  end

  field :transactions, [TransactionInterface], null: false

  def transactions(object, argument_values)
    [
      Charge.new(id: 1, status: "paid", reference: "ch_1234"),
      Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true)
    ]
  end

  field :paymentMethods, [PaymentMethodType], null: false

  def paymentMethods(object, argument_values)
    [
      CreditCard.new(id: 1, last4: "4242"),
      BankAccount.new(id: 32, account_number: "1234567")
    ]
  end
end

class DummySchema < Graphql::DSL::Schema
  query QueryType
end