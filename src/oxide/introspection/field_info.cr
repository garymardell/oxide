module Oxide
  module Introspection
    struct FieldInfo
      include Resolvable

      property name : String
      property field : Oxide::Field

      def initialize(@name, @field)
      end

      def resolve(field_name, argument_values, context, resolution_info) : Result
        case field_name
        when "name"
          name
        when "description"
          nil
        when "args"
          field.arguments.map do |name, argument|
            ArgumentInfo.new(name, argument).as(Resolvable)
          end
        when "type"
          field.type
        when "isDeprecated"
          field.deprecated?
        when "deprecationReason"
          field.deprecation_reason
        end
      end
    end
  end
end