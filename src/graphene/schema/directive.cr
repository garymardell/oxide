module Graphene
  class Schema
    abstract class Directive
      abstract def name : String
      abstract def arguments : Array(Graphene::Schema::Argument)
      abstract def locations : Array(String)

      abstract def include?(object, context, argument_values) : Bool
    end
  end
end