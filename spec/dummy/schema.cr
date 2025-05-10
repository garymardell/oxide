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
      resolve: resolver(Charge | Refund) do
        object.id
      end
    ),
    "reference" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : Charge | Refund, resolution : Oxide::Resolution) { object.reference }
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
      resolve: ->(object : Charge, resolution : Oxide::Resolution) { object.status }
    ),
    "refund" => Oxide::Field.new(
      type: RefundType,
      resolve: ->(object : Charge, resolution : Oxide::Resolution) { Refund.new(object.id, "pending", "r_12345", false) }
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
      resolve: ->(object : Refund, resolution : Oxide::Resolution) { object.status }
    ),
    "partial" => Oxide::Field.new(
      type: Oxide::Types::BooleanType.new,
      resolve: ->(object : Refund, resolution : Oxide::Resolution) { object.partial }
    ),
    "payment_method" => Oxide::Field.new(
      type: PaymentMethodType,
      resolve: ->(object : Refund, resolution : Oxide::Resolution) { BankAccount.new(1, "1234578") }
    )
  }
)

CreditCardType = Oxide::Types::ObjectType.new(
  name: "CreditCard",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new,
      resolve: ->(object : CreditCard, resolution : Oxide::Resolution) { object.id }
    ),
    "last4" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : CreditCard, resolution : Oxide::Resolution) { object.last4 }
    )
  }
)

BankAccountType = Oxide::Types::ObjectType.new(
  name: "BankAccount",
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new,
      resolve: ->(object : BankAccount, resolution : Oxide::Resolution) { object.id }
    ),
    "accountNumber" => Oxide::Field.new(
      type: Oxide::Types::StringType.new,
      resolve: ->(object : BankAccount, resolution : Oxide::Resolution) { object.account_number }
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
        resolve: ->(object : Query, resolution : Oxide::Resolution){
          Charge.new(id: resolution.arguments["id"].to_s.to_i32, status: "pending", reference: "ch_1234")
        },
        arguments: {
          "id" => Oxide::Argument.new(
            type: Oxide::Types::IdType.new
          )
        }
      ),
      "charges" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: ChargeType)
        ),
        resolve: ->(object : Query, resolution : Oxide::Resolution){
          [
            Charge.new(id: 1, status: nil, reference: "ch_1234"),
            Charge.new(id: 2, status: "pending", reference: "ch_5678"),
            Charge.new(id: 3, status: nil, reference: "ch_5678")
          ]
        },
      ),
      "transactions" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: TransactionInterface)
        ),
        resolve: ->(object : Query, resolution : Oxide::Resolution){
          [
            Charge.new(id: 1, status: "paid", reference: "ch_1234"),
            Refund.new(id: 32, status: "refunded", reference: "r_5678", partial: true)
          ]
        }
      ),
      "paymentMethods" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: PaymentMethodType)
        ),
        resolve: ->(object : Query, resolution : Oxide::Resolution){
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
        resolve: ->(object : Query, resolution : Oxide::Resolution){
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
        resolve: ->(object : Query, resolution : Oxide::Resolution) {
          Charge.new(
            id: 1, status: nil, reference: resolution.arguments["input"]["reference"].to_s
          )
        }
      )
    }
  ),
  orphan_types: [
    RefundType.as(Oxide::Type)
  ]
)
