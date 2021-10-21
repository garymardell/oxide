require "./rule"
require "./rules/**"
require "../language/visitor"

module Graphene
  module Validation
    class Pipeline < Graphene::Language::Visitor
      property errors : Array(Error)

      private getter rules : Array(Rule)
      private getter schema : Graphene::Schema
      private getter query : Graphene::Query

      def initialize(@schema, @query)
        @errors = [] of Error
        @rules = [
          # Operations
          OperationNameUniqueness.new(schema).as(Rule),
          LoneAnonymousOperation.new(schema).as(Rule),
          # Fields
          # Arguments
          # Fragments
          FragmentNameUniqueness.new(schema).as(Rule),
          FragmentsMustBeUsed.new(schema).as(Rule),
          # Values
          # Directives
          # Variables
          VariableUniqueness.new(schema).as(Rule)
        ]
      end

      def enter(node)
        rules.each do |rule|
          rule.enter(node)
        end
      end

      def execute
        query.accept(self)
      end

      def errors?
        errors.any?
      end
    end
  end
end