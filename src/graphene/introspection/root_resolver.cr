module Graphene
  module Introspection
    class RootResolver < Graphene::Resolver
      def resolve(object : Resolvable?, field_name, argument_values, context, resolution_info) : Result
        resolution_info.schema
      end
    end
  end
end