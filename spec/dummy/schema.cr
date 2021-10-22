require "../../src/graphene"
require "./models/*"
require "./resolvers/*"

class TransactionTypeResolver < Graphene::Schema::TypeResolver
  def resolve_type(object : Charge, context)
    ChargeType
  end

  def resolve_type(object : Refund, context)
    RefundType
  end
end

TransactionInterface = Graphene::Type::Interface.new(
  name: "Transaction",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Type::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "reference",
      type: Graphene::Type::String.new
    )
  ]
)

ChargeType = Graphene::Type::Object.new(
  name: "Charge",
  implements: [TransactionInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "status",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::Enum.new(
          name: "ChargeStatus",
          values: [
            Graphene::Type::EnumValue.new(name: "PENDING", value: "pending"),
            Graphene::Type::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      )
    ),
    Graphene::Schema::Field.new(
      name: "refund",
      type: RefundType
    )
  ]
)

RefundType = Graphene::Type::Object.new(
  name: "Refund",
  implements: [TransactionInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "status",
      type: Graphene::Type::Enum.new(
        name: "RefundStatus",
        values: [
          Graphene::Type::EnumValue.new(name: "PENDING", value: "pending"),
          Graphene::Type::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    Graphene::Schema::Field.new(
      name: "partial",
      type: Graphene::Type::Boolean.new
    ),
    Graphene::Schema::Field.new(
      name: "payment_method",
      type: PaymentMethodType
    )
  ]
)

CreditCardType = Graphene::Type::Object.new(
  name: "CreditCard",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Type::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "last4",
      type: Graphene::Type::String.new
    )
  ]
)

BankAccountType = Graphene::Type::Object.new(
  name: "BankAccount",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Type::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "accountNumber",
      type: Graphene::Type::String.new
    )
  ]
)

class PaymentMethodTypeResolver < Graphene::Schema::TypeResolver
  def resolve_type(object : CreditCard, context)
    CreditCardType
  end

  def resolve_type(object : BankAccount, context)
    BankAccountType
  end
end

PaymentMethodType = Graphene::Type::Union.new(
  name: "PaymentMethod",
  possible_types: [
    CreditCardType.as(Graphene::Type),
    BankAccountType.as(Graphene::Type)
  ]
)

DummySchema = Graphene::Schema.new(
  query: Graphene::Type::Object.new(
    name: "Query",
    fields: [
      Graphene::Schema::Field.new(
        name: "charge",
        type: Graphene::Type::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphene::Schema::Argument.new(
            name: "id",
            type: Graphene::Type::Id.new
          )
        ]
      ),
      Graphene::Schema::Field.new(
        name: "charges",
        type: Graphene::Type::NonNull.new(
          of_type: Graphene::Type::List.new(of_type: ChargeType)
        )
      ),
      Graphene::Schema::Field.new(
        name: "transactions",
        type: Graphene::Type::NonNull.new(
          of_type: Graphene::Type::List.new(of_type: TransactionInterface)
        )
      ),
      Graphene::Schema::Field.new(
        name: "paymentMethods",
        type: Graphene::Type::NonNull.new(
          of_type: Graphene::Type::List.new(of_type: PaymentMethodType)
        )
      ),
      Graphene::Schema::Field.new(
        name: "nullList",
        type: Graphene::Type::List.new(
          of_type: Graphene::Type::NonNull.new(of_type: ChargeType)
        )
      )
    ]
  ),
  mutation: nil,
  orphan_types: [
    RefundType.as(Graphene::Type)
  ]
)

DummySchemaResolvers = {
  "Query" => QueryResolver.new.as(Graphene::Schema::Resolvable),
  "BankAccount" => BankAccountResolver.new.as(Graphene::Schema::Resolvable),
  "Charge" => ChargeResolver.new.as(Graphene::Schema::Resolvable),
  "CreditCard" => CreditCardResolver.new.as(Graphene::Schema::Resolvable),
  "Refund" => RefundResolver.new.as(Graphene::Schema::Resolvable),
}

DummySchemaTypeResolvers = {
  "Transaction" => TransactionTypeResolver.new,
  "PaymentMethod" => PaymentMethodTypeResolver.new
}