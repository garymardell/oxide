class RefundLoader < Graphene::Loader(Int32, Refund?)
  def perform(load_keys)
    load_keys.each do |key|
      fulfill(key, Refund.new(key, "pending", "r_12345", false))
    end
  end
end

class ChargeResolver < Graphene::Schema::Resolver
  property loader : RefundLoader

  def initialize
    @loader = RefundLoader.new
  end

  def resolve(object : Charge, context, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    when "reference"
      object.reference
    when "refund"
      loader.load(object.id)
    end
  end
end
