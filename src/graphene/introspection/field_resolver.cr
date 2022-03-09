module Graphene
  module Introspection
    struct ArgumentInfo
      property name : String
      property argument : Graphene::Argument

      def initialize(@name, @argument)
      end
    end

    class FieldResolver < Graphene::Resolver
      def resolve(object : FieldInfo, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          nil
        when "args"
          object.field.arguments.map do |name, argument|
            ArgumentInfo.new(name, argument)
          end
        when "type"
          object.field.type
        when "isDeprecated"
          object.field.deprecated?
        when "deprecationReason"
          object.field.deprecation_reason
        end
      end
    end
  end
end