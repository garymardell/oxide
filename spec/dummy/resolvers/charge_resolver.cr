class RefundLoader < Oxide::Loader(Int32, Refund?)
  def perform(load_keys)
    load_keys.each do |key|
      fulfill(key, Refund.new(key, "pending", "r_12345", false))
    end
  end
end

class ChargeResolver
  include Oxide::Resolves(Charge)

  property loader : RefundLoader

  def initialize
    @loader = RefundLoader.new
  end

  def resolve(object : Charge, field_name, argument_values, context, resolution_info)
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
