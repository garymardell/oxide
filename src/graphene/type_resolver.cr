module Graphene
  abstract class TypeResolver
    def resolve_type(object, context)
      raise "Could not resolve union type"
    end
  end

  class NullTypeResolver < TypeResolver
    def resolve_type(object, context)
      nil
    end
  end
end