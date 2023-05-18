class DynamicResolver < Graphene::Resolver
  def resolve(object : Graphene::Resolvable?, field_name, argument_values, context, resolution_info) : Graphene::Result
    field_name
  end

  def resolve(object, field_name, argument_values, context, resolution_info)
    field_name
  end
end
