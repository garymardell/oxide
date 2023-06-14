require "./resolvable"

module Oxide
  module Resolver
    abstract def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
  end

  class DefaultResolver
    include Resolver

    def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
      if object
        object.resolve(field_name, argument_values, context, resolution_info)
      end
    end
  end

  class NullResolver
    include Resolver

    def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
      nil
    end
  end
end
