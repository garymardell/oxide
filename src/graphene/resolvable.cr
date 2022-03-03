module Graphene
  module Resolvable
    abstract def resolve(object, field_name, argument_values, context, resolution_info)
  end
end