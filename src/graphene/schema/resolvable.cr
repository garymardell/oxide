module Graphene
  class Schema
    module Resolvable
      property schema : Graphene::Schema?

      abstract def resolve(object, context, field_name, argument_values)
    end
  end
end