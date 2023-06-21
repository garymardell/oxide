class DynamicResolver
  include Oxide::Resolver

  def resolve(object, field_name, argument_values, context, resolution_info)
    field_name
  end
end
