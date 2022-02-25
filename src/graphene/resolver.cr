require "./resolvable"

module Graphene
  abstract class Resolver
    include Resolvable

    def resolve(object, context, field_name, argument_values)
      raise "no resolver defined for field #{field_name} on #{self.class.name} for #{object.class.name}"
    end
  end

  class NullResolver < Resolver
    def resolve(object, context, field_name, argument_values)
      nil
    end
  end
end
