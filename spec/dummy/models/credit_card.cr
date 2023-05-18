class CreditCard
  include Graphene::Resolvable

  property id : Int32
  property last4 : String

  def initialize(@id, @last4)
  end

  def resolve(field_name, argument_values, context, resolution_info) : Graphene::Result
    case field_name
    when "id"
      id
    when "last4"
      last4
    end
  end
end