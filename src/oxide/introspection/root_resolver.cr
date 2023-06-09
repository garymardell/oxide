module Oxide
  module Introspection
    class RootResolver
      include Oxide::Resolver

      def resolve(object, field_name, argument_values, context, resolution_info)
        resolution_info.schema
      end
    end
  end
end