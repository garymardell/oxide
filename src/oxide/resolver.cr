require "./resolvable"

module Oxide
  module Resolver
    abstract def resolve(object, field_name, argument_values, context, resolution_info)
  end

  module Resolves(T)
    include Resolver

    abstract def resolve(object : T, field_name, argument_values, context, resolution_info)

    def resolve(object, field_name, argument_values, context, resolution_info)
      raise "resolve not implemented"
    end
  end

  class DefaultResolver
    include Resolver

    def resolve(object : Resolvable, field_name, argument_values, context, resolution_info)
      object.resolve(field_name, argument_values, context, resolution_info)
    end

    def resolve(object, field_name, argument_values, context, resolution_info)
      raise "resolver must be specified unless object implements Resolvable"
    end
  end

  class NullResolver
    include Resolver

    def resolve(object, field_name, argument_values, context, resolution_info)
      nil
    end
  end
end
