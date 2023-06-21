module Oxide
  module Introspection
    struct ArgumentInfo
      include Resolvable

      property name : String
      property argument : Oxide::Argument

      def initialize(@name, @argument)
      end

      def resolve(field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          name
        when "description"
          argument.description
        when "type"
          argument.type
        when "defaultValue"
          argument.default_value
        end
      end
    end
  end
end