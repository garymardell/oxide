module Graphene
  module Introspection
    struct ArgumentInfo
      include Resolvable

      property name : String
      property argument : Graphene::Argument

      def initialize(@name, @argument)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "type"
          argument.type
        end
      end
    end
  end
end