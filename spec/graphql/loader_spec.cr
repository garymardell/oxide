require "../spec_helper"

class ChargeLoader < Loader(Charge, Int32)
  def perform(keys)
    keys.each do |key|
      fulfill(key, Charge.new(id: key, status: "pending", reference: "ch_1234", receipt_id: 1))
    end
  end
end

describe Loader do
  it "loader" do
    loader = ChargeLoader.new

    promise1 = loader.load(1)
    promise2 = loader.load(2)

    loader.resolve

    pp promise1.get
    pp promise2.get
  end
end