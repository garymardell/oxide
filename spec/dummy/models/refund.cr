class Refund
  include Graphene::Resolvable

  property id : Int32
  property status : String
  property partial : Bool
  property reference : String

  def initialize(@id, @status, @reference, @partial)
  end

  def resolve(field_name, argument_values, context, resolution_info) : Graphene::Result
    case field_name
    when "id"
      id
    when "status"
      status
    when "partial"
      partial
    when "reference"
      reference
    end
  end
end