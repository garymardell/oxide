class Charge
  property id : Int32
  property status : String?
  property reference : String
  property refund_id : Int32?

  def initialize(@id, @reference, @status = nil, @refund_id = nil)
  end
end