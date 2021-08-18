require "../../src/graphql"
require "./models/*"
require "./resolvers/*"

class TransactionTypeResolver < Graphql::Schema::TypeResolver
  def resolve_type(object : Charge)
    ChargeType
  end

  def resolve_type(object : Refund)
    RefundType
  end
end

TransactionInterface = Graphql::Type::Interface.new(
  name: "Transaction",
  type_resolver: TransactionTypeResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "id",
      type: Graphql::Type::Id.new
    ),
    Graphql::Schema::Field.new(
      name: "reference",
      type: Graphql::Type::String.new
    )
  ]
)

ChargeType = Graphql::Type::Object.new(
  typename: "Charge",
  resolver: ChargeResolver.new,
  implements: [TransactionInterface],
  fields: [
    Graphql::Schema::Field.new(
      name: "status",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::Enum.new(
          typename: "ChargeStatus",
          values: [
            Graphql::Type::EnumValue.new(name: "PENDING", value: "pending"),
            Graphql::Type::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      )
    ),
    Graphql::Schema::Field.new(
      name: "refund",
      type: RefundType
    )
  ]
)

RefundType = Graphql::Type::Object.new(
  typename: "Refund",
  resolver: RefundResolver.new,
  implements: [TransactionInterface],
  fields: [
    Graphql::Schema::Field.new(
      name: "status",
      type: Graphql::Type::Enum.new(
        typename: "RefundStatus",
        values: [
          Graphql::Type::EnumValue.new(name: "PENDING", value: "pending"),
          Graphql::Type::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    Graphql::Schema::Field.new(
      name: "partial",
      type: Graphql::Type::Boolean.new
    ),
    Graphql::Schema::Field.new(
      name: "payment_method",
      type: PaymentMethodType
    )
  ]
)

CreditCardType = Graphql::Type::Object.new(
  typename: "CreditCard",
  resolver: CreditCardResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "id",
      type: Graphql::Type::Id.new
    ),
    Graphql::Schema::Field.new(
      name: "last4",
      type: Graphql::Type::String.new
    )
  ]
)

BankAccountType = Graphql::Type::Object.new(
  typename: "BankAccount",
  resolver: BankAccountResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "id",
      type: Graphql::Type::Id.new
    ),
    Graphql::Schema::Field.new(
      name: "accountNumber",
      type: Graphql::Type::String.new
    )
  ]
)

class PaymentMethodTypeResolver < Graphql::Schema::TypeResolver
  def resolve_type(object : CreditCard)
    CreditCardType
  end

  def resolve_type(object : BankAccount)
    BankAccountType
  end
end

PaymentMethodType = Graphql::Type::Union.new(
  typename: "PaymentMethod",
  type_resolver: PaymentMethodTypeResolver.new,
  possible_types: [
    CreditCardType.as(Graphql::Type),
    BankAccountType.as(Graphql::Type)
  ]
)

DummySchema = Graphql::Schema.new(
  query: Graphql::Type::Object.new(
    typename: "Query",
    resolver: QueryResolver.new,
    fields: [
      Graphql::Schema::Field.new(
        name: "charge",
        type: Graphql::Type::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphql::Schema::Argument.new(
            name: "id",
            type: Graphql::Type::Id.new
          )
        ]
      ),
      Graphql::Schema::Field.new(
        name: "charges",
        type: Graphql::Type::NonNull.new(
          of_type: Graphql::Type::List.new(of_type: ChargeType)
        )
      ),
      Graphql::Schema::Field.new(
        name: "transactions",
        type: Graphql::Type::NonNull.new(
          of_type: Graphql::Type::List.new(of_type: TransactionInterface)
        )
      ),
      Graphql::Schema::Field.new(
        name: "paymentMethods",
        type: Graphql::Type::NonNull.new(
          of_type: Graphql::Type::List.new(of_type: PaymentMethodType)
        )
      ),
      Graphql::Schema::Field.new(
        name: "nullList",
        type: Graphql::Type::List.new(
          of_type: Graphql::Type::NonNull.new(of_type: ChargeType)
        )
      )
    ]
  ),
  mutation: nil,
  orphan_types: [
    RefundType.as(Graphql::Type)
  ]
)