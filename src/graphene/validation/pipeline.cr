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

      private getter context : Context

      def initialize(@schema, @query, rules = nil)
        @errors = [] of Error
        @rules = rules || all_rules
        @context = Context.new(
          schema,
          query
        )
      end

      def enter(node)
        rules.each do |rule|
          rule.enter(node, context)
        end
      end

      def exit(node)
        rules.each do |rule|
          rule.exit(node, context)
        end
      end

      def execute
        query.accept(self)

        rules.each do |rule|
          errors.concat rule.errors
        end
      end

      def errors?
        errors.any?
      end

      private def all_rules
        [
          # Operations
          OperationNameUniqueness.new.as(Rule),
          LoneAnonymousOperation.new.as(Rule),
          # Fields
          # Arguments
          # Fragments
          FragmentNameUniqueness.new.as(Rule),
          FragmentsMustBeUsed.new.as(Rule),
          # Values
          # Directives
          # Variables
          VariableUniqueness.new.as(Rule)
        ]
      end
    end
  end
end