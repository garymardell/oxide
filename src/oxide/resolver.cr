require "./resolvable"

module Oxide
  abstract class Resolver
    abstract def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
  end

  class DefaultResolver < Resolver
    def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
      if object
        object.resolve(field_name, argument_values, context, resolution_info)
      end
    end
  end

  class NullResolver < Resolver
    def resolve(object, field_name, argument_values, context, resolution_info) : Result
      nil
    end
  end
end
