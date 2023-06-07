require "./rule"
require "./rules/**"
require "../language/visitor"

module Graphene
  module Validation
    class Pipeline < Graphene::Language::Visitor
      private getter rules : Array(Rule)
      private getter schema : Graphene::Schema
      private getter query : Graphene::Query

      private getter context : Context
      private getter context_visitor : ContextVisitor

      delegate errors, to: context

      def initialize(@schema, @query, rules = nil)
        @rules = rules || all_rules
        @context = Context.new(
          schema,
          query
        )
        @context_visitor = ContextVisitor.new(context)
      end

      def enter(node)
        context_visitor.enter(node)

        rules.each do |rule|
          rule.enter(node, context)
        end
      end

      def leave(node)
        context_visitor.leave(node)

        rules.each do |rule|
          rule.leave(node, context)
        end
      end

      def execute : Hash(String, Array(Graphene::Error))?
        query.accept(self)

        if errors?
          { "errors" => context.errors }
        end
      end

      def errors?
        context.errors.any?
      end

      private def all_rules
        [
          # Operations
          OperationNameUniqueness.new.as(Rule),
          LoneAnonymousOperation.new.as(Rule),
          # Fields
          FieldSelections.new.as(Rule),
          LeafFieldSelections.new.as(Rule),
          # Arguments
          ArgumentNames.new.as(Rule),
          ArgumentUniqueness.new.as(Rule),
          # Fragments
          # FragmentNameUniqueness.new.as(Rule),
          # FragmentsMustBeUsed.new.as(Rule),
          # Values
          # Directives
          DirectivesAreDefined.new.as(Rule),
          DirectivesAreInValidLocations.new.as(Rule),
          # Variables
          VariableUniqueness.new.as(Rule),
          VariablesAreInputTypes.new.as(Rule),
          AllVariableUsesDefined.new.as(Rule)
        ]
      end
    end
  end
end