require "../loader"

class ReceiptLoader < Loader(Receipt, Int32)
  def perform(keys)
    pp keys
    keys.each do |key|
      fulfill(key, Receipt.new(id: key))
    end
  end
end

class ChargeResolver < Graphql::Schema::Resolver
  property receipt_loader : ReceiptLoader

  def initialize
    @receipt_loader = ReceiptLoader.new
  end

  def resolve(object : Charge, field_name, argument_values)
    case field_name
    when "id"
      object.id
    when "status"
      object.status
    when "reference"
      object.reference
    when "receipt"
      receipt_loader.load(object.receipt_id)
    end
  end
end
