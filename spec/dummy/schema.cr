require "../../src/oxide"
require "./models/*"

class TransactionTypeResolver < Oxide::TypeResolver
  def resolve_type(object : Charge, context)
    ChargeType
  end

  def resolve_type(object : Refund, context)
    RefundType
  end

  def resolve_type(object, context)
    raise "Could not resolve transaction type"
  end
end

TransactionInterface = Oxide::Types::InterfaceType.new(
  name: "Transaction",
  type_resolver: TransactionTypeResolver.new,
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new,
      resolve: ->(transaction : Charge | Refund){
        transaction.id
      }
    ),
    "reference" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(transaction : Charge | Refund){ transaction.reference }
    )
  }
)

ChargeType = Oxide::Types::ObjectType.new(
  name: "Charge",
  interfaces: [TransactionInterface],
  fields: {
    "status" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type:  Oxide::Types::EnumType.new(
          name: "ChargeStatus",
          values: [
            Oxide::Types::EnumValue.new(name: "PENDING", value: "pending"),
            Oxide::Types::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      ),
      resolve: ->(charge : Charge) { charge.status }
    ),
    "refund" => Oxide::Field.new(
      type: RefundType,
      resolve: ->(charge : Charge) { Refund.new(charge.id, "pending", "r_12345", false) }
    )
  }
)

RefundType = Oxide::Types::ObjectType.new(
  name: "Refund",
  interfaces: [TransactionInterface],
  fields: {
    "status" => Oxide::Field.new(
      type: Oxide::Types::EnumType.new(
        name: "RefundStatus",
        values: [
          Oxide::Types::EnumValue.new(name: "PENDING", value: "pending"),
          Oxide::Types::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      ),
      resolve: ->(refund : Refund) { refund.status }
    ),
    "partial" => Oxide::Field.new(
      type: Oxide::Types::BooleanType.new,
      resolve: ->(refund : Refund) { refund.partial }
    ),
    "payment_method" => Oxide::Field.new(
      type: PaymentMethodType,
      resolve: ->(refund : Refund) { BankAccount.new(1, "1234578") }
    )
  }
)

CreditCardType = Oxide::Types::ObjectType.new(
  name: "CreditCard",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new,
      resolve: ->(credit_card : CreditCard) { credit_card.id }
    ),
    "last4" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(credit_card : CreditCard) { credit_card.last4 }
    )
  }
)

BankAccountType = Oxide::Types::ObjectType.new(
  name: "BankAccount",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new,
      resolve: ->(bank_account : BankAccount) { bank_account.id }
    ),
    "accountNumber" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(bank_account : BankAccount) { bank_account.account_number }
    )
  }
)

class PaymentMethodTypeResolver < Oxide::TypeResolver
  def resolve_type(object : CreditCard, context)
    CreditCardType
  end

  def resolve_type(object : BankAccount, context)
    BankAccountType
  end

  def resolve_type(object, context)
    raise "Could not resolve payment method type"
  end
end

PaymentMethodType = Oxide::Types::UnionType.new(
  name: "PaymentMethod",
  type_resolver: PaymentMethodTypeResolver.new,
  possible_types: [
    CreditCardType.as(Oxide::Type),
    BankAccountType.as(Oxide::Type)
  ]
)

CreateChargeInputObject = Oxide::Types::InputObjectType.new(
  name: "CreateChargeInput",
  input_fields: {
    "reference" => Oxide::Argument.new(
      type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new)
    )
  }
)

DummySchema = Oxide::Schema.new(
  query: Oxide::Types::ObjectType.new(
    name: "Query",
    fields: {
      "charge" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(of_type: ChargeType),
        resolve: ->(query : Query, arguments : Oxide::ArgumentValues){
          Charge.new(id: arguments["id"].to_s.to_i32, status: "pending", reference: "ch_1234")
        },
        arguments: {
          "id" => Oxide::Argument.new(
            type: Oxide::Types::IdType.new
          )
        }
      ),
      "charges" => Oxide::Field(Query, Array(Charge)).new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: ChargeType)
        ),
        resolve: ->(query : Query){
          [
            Charge.new(id: 1, status: nil, reference: "ch_1234"),
            Charge.new(id: 2, status: "pending", reference: "ch_5678"),
            Charge.new(id: 3, status: nil, reference: "ch_5678")
          ]
        },
      ),
      "transactions" => Oxide::Field(Query, Array(Charge | Refund)).new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: TransactionInterface)
        ),
        resolve: ->(query : Query){
          [
            Charge.new(id: 1, status: "paid", reference: "ch_1234"),
            Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true)
          ]
        }
      ),
      "paymentMethods" => Oxide::Field(Query, Array(BankAccount | CreditCard)).new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: PaymentMethodType)
        ),
        resolve: ->(query : Query) {
          [
            CreditCard.new(id: 1, last4: "4242"),
            BankAccount.new(id: 32, account_number: "1234567")
          ]
        }
      ),
      "nullList" => Oxide::Field.new(
        type: Oxide::Types::ListType.new(
          of_type: Oxide::Types::NonNullType.new(of_type: ChargeType)
        ),
        resolve: ->(query : Query) {
          [nil]
        }
      )
    }
  ),
  mutation: Oxide::Types::ObjectType.new(
    name: "Mutation",
    fields: {
      "createCharge" => Oxide::Field.new(
        type: ChargeType,
        arguments: {
          "input" => Oxide::Argument.new(
            type: CreateChargeInputObject
          )
        },
        resolve: ->(query : Query) {
          nil
        }
      )
    }
  ),
  subscription: Oxide::Types::ObjectType.new(
    name: "Subscription",
    fields: {
      "feed" => Oxide::Field.new(
        type: ChargeType,
        resolve: ->(query : Query) {
          nil
        }
      )
    }
  ),
  orphan_types: [
    RefundType.as(Oxide::Type)
  ]
)