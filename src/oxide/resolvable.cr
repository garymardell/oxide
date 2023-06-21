module Oxide
  module Resolvable
    abstract def resolve(field_name, argument_values, context, resolution_info)
  end
end