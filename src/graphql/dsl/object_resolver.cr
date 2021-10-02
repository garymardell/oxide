require "./object"

module Graphql
  module DSL
    class ObjectResolver < Graphql::Schema::Resolver
      def initialize(klass : Graphql::DSL::Object.class)
        @klass = klass
      end

      def resolve(object, field_name, argument_values)
        @klass.resolve(object, field_name, argument_values)
      end
    end
  end
end