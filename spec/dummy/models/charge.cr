class Charge
  property id : Int32
  property status : String?
  property reference : String
  property receipt_id : Int32

  def initialize(@id, @reference, @receipt_id, @status = nil)
  end
end