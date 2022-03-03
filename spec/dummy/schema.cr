require "../../src/graphene"
require "./models/*"
require "./resolvers/*"

class TransactionTypeResolver < Graphene::TypeResolver
  def resolve_type(object : Charge, context)
    ChargeType
  end

  def resolve_type(object : Refund, context)
    RefundType
  end
end

TransactionInterface = Graphene::Types::InterfaceType.new(
  name: "Transaction",
  type_resolver: TransactionTypeResolver.new,
  fields: {
    "id" => Graphene::Field.new(
      name: "id",
      type: Graphene::Types::IdType.new
    ),
    "reference" => Graphene::Field.new(
      name: "reference",
      type: Graphene::Types::StringType.new
    )
  }
)

ChargeType = Graphene::Types::ObjectType.new(
  name: "Charge",
  resolver: ChargeResolver.new,
  interfaces: [TransactionInterface],
  fields: {
    "status" => Graphene::Field.new(
      name: "status",
      type: Graphene::Types::NonNullType.new(
        of_type: Graphene::Types::EnumType.new(
          name: "ChargeStatus",
          values: [
            Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
            Graphene::Types::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      )
    ),
    "refund" => Graphene::Field.new(
      name: "refund",
      type: RefundType
    )
  }
)

RefundType = Graphene::Types::ObjectType.new(
  name: "Refund",
  resolver: RefundResolver.new,
  interfaces: [TransactionInterface],
  fields: {
    "status" => Graphene::Field.new(
      name: "status",
      type: Graphene::Types::EnumType.new(
        name: "RefundStatus",
        values: [
          Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
          Graphene::Types::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    "partial" => Graphene::Field.new(
      name: "partial",
      type: Graphene::Types::BooleanType.new
    ),
    "payment_method" => Graphene::Field.new(
      name: "payment_method",
      type: PaymentMethodType
    )
  }
)

CreditCardType = Graphene::Types::ObjectType.new(
  name: "CreditCard",
  resolver: CreditCardResolver.new,
  fields: {
    "id" => Graphene::Field.new(
      name: "id",
      type: Graphene::Types::IdType.new
    ),
    "last4" => Graphene::Field.new(
      name: "last4",
      type: Graphene::Types::StringType.new
    )
  }
)

BankAccountType = Graphene::Types::ObjectType.new(
  name: "BankAccount",
  resolver: BankAccountResolver.new,
  fields: {
    "id" => Graphene::Field.new(
      name: "id",
      type: Graphene::Types::IdType.new
    ),
    "accountNumber" => Graphene::Field.new(
      name: "accountNumber",
      type: Graphene::Types::StringType.new
    )
  }
)

class PaymentMethodTypeResolver < Graphene::TypeResolver
  def resolve_type(object : CreditCard, context)
    CreditCardType
  end

  def resolve_type(object : BankAccount, context)
    BankAccountType
  end
end

PaymentMethodType = Graphene::Types::UnionType.new(
  name: "PaymentMethod",
  type_resolver: PaymentMethodTypeResolver.new,
  possible_types: [
    CreditCardType.as(Graphene::Type),
    BankAccountType.as(Graphene::Type)
  ]
)

DummySchema = Graphene::Schema.new(
  query: Graphene::Types::ObjectType.new(
    name: "Query",
    resolver: QueryResolver.new,
    fields: {
      "charge" => Graphene::Field.new(
        name: "charge",
        type: Graphene::Types::NonNullType.new(of_type: ChargeType),
        arguments: [
          Graphene::Argument.new(
            name: "id",
            type: Graphene::Types::IdType.new
          )
        ]
      ),
      "charges" => Graphene::Field.new(
        name: "charges",
        type: Graphene::Types::NonNullType.new(
          of_type: Graphene::Types::ListType.new(of_type: ChargeType)
        )
      ),
      "transactions" => Graphene::Field.new(
        name: "transactions",
        type: Graphene::Types::NonNullType.new(
          of_type: Graphene::Types::ListType.new(of_type: TransactionInterface)
        )
      ),
      "paymentMethods" => Graphene::Field.new(
        name: "paymentMethods",
        type: Graphene::Types::NonNullType.new(
          of_type: Graphene::Types::ListType.new(of_type: PaymentMethodType)
        )
      ),
      "nullList" => Graphene::Field.new(
        name: "nullList",
        type: Graphene::Types::ListType.new(
          of_type: Graphene::Types::NonNullType.new(of_type: ChargeType)
        )
      )
    }
  ),
  mutation: nil,
  orphan_types: [
    RefundType.as(Graphene::Type)
  ]
)