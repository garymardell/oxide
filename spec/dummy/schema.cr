require "../../src/oxide"
require "./models/*"
require "./resolvers/*"

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
      type: Oxide::Types::IdType.new
    ),
    "reference" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
    )
  }
)

ChargeType = Oxide::Types::ObjectType.new(
  name: "Charge",
  resolver: ChargeResolver.new,
  interfaces: [TransactionInterface],
  fields: {
    "status" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::EnumType.new(
          name: "ChargeStatus",
          values: [
            Oxide::Types::EnumValue.new(name: "PENDING", value: "pending"),
            Oxide::Types::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      )
    ),
    "refund" => Oxide::Field.new(
      type: RefundType
    )
  }
)

RefundType = Oxide::Types::ObjectType.new(
  name: "Refund",
  resolver: RefundResolver.new,
  interfaces: [TransactionInterface],
  fields: {
    "status" => Oxide::Field.new(
      type: Oxide::Types::EnumType.new(
        name: "RefundStatus",
        values: [
          Oxide::Types::EnumValue.new(name: "PENDING", value: "pending"),
          Oxide::Types::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    "partial" => Oxide::Field.new(
      type: Oxide::Types::BooleanType.new
    ),
    "payment_method" => Oxide::Field.new(
      type: PaymentMethodType
    )
  }
)

CreditCardType = Oxide::Types::ObjectType.new(
  name: "CreditCard",
  resolver: CreditCardResolver.new,
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new
    ),
    "last4" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
    )
  }
)

BankAccountType = Oxide::Types::ObjectType.new(
  name: "BankAccount",
  resolver: BankAccountResolver.new,
  fields: {
    "id" => Oxide::Field.new(
      type: Oxide::Types::IdType.new
    ),
    "accountNumber" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
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
        arguments: {
          "id" => Oxide::Argument.new(
            type: Oxide::Types::IdType.new
          )
        }
      ),
      "charges" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: ChargeType)
        )
      ),
      "transactions" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: TransactionInterface)
        )
      ),
      "paymentMethods" => Oxide::Field.new(
        type: Oxide::Types::NonNullType.new(
          of_type: Oxide::Types::ListType.new(of_type: PaymentMethodType)
        )
      ),
      "nullList" => Oxide::Field.new(
        type: Oxide::Types::ListType.new(
          of_type: Oxide::Types::NonNullType.new(of_type: ChargeType)
        )
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
        }
      )
    }
  ),
  orphan_types: [
    RefundType.as(Oxide::Type)
  ]
)