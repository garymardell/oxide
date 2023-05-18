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
        when "description"
          argument.description
        when "type"
          argument.type
        when "defaultValue"
          argument.default_value.as(Result)
        end
      end
    end
  end
end