class DynamicResolver < Oxide::Resolver
  def resolve(object : Oxide::Resolvable?, field_name, argument_values, context, resolution_info) : Oxide::Result
    field_name
  end

  def resolve(object, field_name, argument_values, context, resolution_info)
    field_name
  end
end
