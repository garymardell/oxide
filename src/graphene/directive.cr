module Graphene
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
    end

    abstract def name : String
    abstract def arguments : Array(Graphene::Argument)
    abstract def locations : Array(Location)

    abstract def include?(object, context, argument_values) : Bool
  end
end