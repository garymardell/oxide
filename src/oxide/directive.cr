module Oxide
  abstract class Directive
    include Resolvable

    enum Location
      # Executeable directives
      QUERY
      MUTATION
      SUBSCRIPTION
      FIELD
      FRAGMENT_DEFINITION
      FRAGMENT_SPREAD
      INLINE_FRAGMENT

      # Type system directives
      SCHEMA
      SCALAR
      OBJECT
      FIELD_DEFINITION
      ARGUMENT_DEFINITION
      INTERFACE
      UNION
      ENUM
      ENUM_VALUE
      INPUT_OBJECT
      INPUT_FIELD_DEFINITION

      def to_human
        case self
        when QUERY
          "queries"
        when MUTATION
          "mutations"
        when SUBSCRIPTION
          "subscriptions"
        when FIELD
          "fields"
        when FRAGMENT_SPREAD
          "fragment spreads"
        when INLINE_FRAGMENT
          "inline fragments"
        else
          to_s
        end
      end
    end

    abstract def name : String
    abstract def arguments : Hash(String, Oxide::Argument)
    abstract def locations : Array(Location)

    abstract def include?(object, context, argument_values) : Bool

    def resolve(field_name, argument_values, context, resolution_info)
      case field_name
      when "name"
        name
      when "args"
        arguments.map { |name, argument| Introspection::ArgumentInfo.new(name, argument).as(Resolvable) }
      when "locations"
        locations.map { |location| location.to_s }
      end
    end
  end
end