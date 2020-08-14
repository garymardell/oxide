class Refund
  property id : Int32
  property status : String
  property partial : Bool

  def initialize(@id, @status, @partial)
  end
end