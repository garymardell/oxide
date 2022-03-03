require "./resolvable"

module Graphene
  abstract class Resolver
    include Resolvable

    def resolve(object, field_name, argument_values, context, resolution_info)
      raise "no resolver defined for field #{field_name} on #{self.class.name} for #{object.class.name}"
    end
  end

  class NullResolver < Resolver
    def resolve(object, field_name, argument_values, context, resolution_info)
      nil
    end
  end
end
