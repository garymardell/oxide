class Charge
  property id : Int32
  property status : String
  property reference : String

  def initialize(@id, @status, @reference)
  end
end