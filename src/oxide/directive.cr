module Oxide
  abstract class Directive
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
  end
end