class Charge
  include Oxide::Resolvable

  property id : Int32
  property status : String?
  property reference : String

  def initialize(@id, @reference, @status = nil)
  end

  def resolve(field_name, argument_values, context, resolution_info) : Oxide::Result
    case field_name
    when "id"
      id
    when "status"
      status
    when "reference"
      reference
    end
  end
end