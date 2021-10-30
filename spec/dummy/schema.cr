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

TransactionInterface = Graphene::Types::Interface.new(
  name: "Transaction",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "reference",
      type: Graphene::Types::String.new
    )
  ]
)

ChargeType = Graphene::Types::Object.new(
  name: "Charge",
  implements: [TransactionInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "status",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::Enum.new(
          name: "ChargeStatus",
          values: [
            Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
            Graphene::Types::EnumValue.new(name: "PAID", value: "paid")
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

RefundType = Graphene::Types::Object.new(
  name: "Refund",
  implements: [TransactionInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "status",
      type: Graphene::Types::Enum.new(
        name: "RefundStatus",
        values: [
          Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
          Graphene::Types::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    Graphene::Schema::Field.new(
      name: "partial",
      type: Graphene::Types::Boolean.new
    ),
    Graphene::Schema::Field.new(
      name: "payment_method",
      type: PaymentMethodType
    )
  ]
)

CreditCardType = Graphene::Types::Object.new(
  name: "CreditCard",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "last4",
      type: Graphene::Types::String.new
    )
  ]
)

BankAccountType = Graphene::Types::Object.new(
  name: "BankAccount",
  fields: [
    Graphene::Schema::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Schema::Field.new(
      name: "accountNumber",
      type: Graphene::Types::String.new
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

PaymentMethodType = Graphene::Types::Union.new(
  name: "PaymentMethod",
  possible_types: [
    CreditCardType.as(Graphene::Type),
    BankAccountType.as(Graphene::Type)
  ]
)

DummySchema = Graphene::Schema.new(
  query: Graphene::Types::Object.new(
    name: "Query",
    fields: [
      Graphene::Schema::Field.new(
        name: "charge",
        type: Graphene::Types::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphene::Schema::Argument.new(
            name: "id",
            type: Graphene::Types::Id.new
          )
        ]
      ),
      Graphene::Schema::Field.new(
        name: "charges",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: ChargeType)
        )
      ),
      Graphene::Schema::Field.new(
        name: "transactions",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: TransactionInterface)
        )
      ),
      Graphene::Schema::Field.new(
        name: "paymentMethods",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: PaymentMethodType)
        )
      ),
      Graphene::Schema::Field.new(
        name: "nullList",
        type: Graphene::Types::List.new(
          of_type: Graphene::Types::NonNull.new(of_type: ChargeType)
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