require "./rule"
require "./rules/**"
require "../language/visitor"

module Oxide
  module Validation
    class Runtime < Oxide::Language::Visitor
      private getter rules : Array(Rule)
      private getter schema : Oxide::Schema
      private getter query : Oxide::Query

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

      def execute
        query.accept(self)
      end

      def execute!
        execute

        if errors?
          raise Oxide::CombinedError.new(context.errors)
        end
      end

      def errors?
        context.errors.any?
      end

      private def all_rules
        [
          # 5.1 Documents
          ExecutableDefinitions.new.as(Rule),
          # 5.2 Operations
          OperationNameUniqueness.new.as(Rule),
          LoneAnonymousOperation.new.as(Rule),
          OperationTypeExistence.new.as(Rule),
          # 5.3 Fields
          FieldSelections.new.as(Rule),
          FieldSelectionMerging.new.as(Rule),
          LeafFieldSelections.new.as(Rule),
          # 5.4 Arguments
          ArgumentNames.new.as(Rule),
          ArgumentUniqueness.new.as(Rule),
          RequiredArguments.new.as(Rule),
          # 5.5 Fragments
          FragmentNameUniqueness.new.as(Rule),
          FragmentSpreadTypeExistence.new.as(Rule),
          FragmentsOnCompositeTypes.new.as(Rule),
          FragmentsMustBeUsed.new.as(Rule),
          FragmentSpreadTargetDefined.new.as(Rule),
          FragmentSpreadsMusNotFormCycles.new.as(Rule),
          FragmentSpreadIsPossible.new.as(Rule),
          # 5.6 Values
          ValuesOfCorrectType.new.as(Rule),
          InputObjectFieldNames.new.as(Rule),
          InputObjectFieldUniqueness.new.as(Rule),
          InputObjectRequiredFields.new.as(Rule),
          OneOfInputObjects.new.as(Rule),
          # 5.7 Directives
          DirectivesAreDefined.new.as(Rule),
          DirectivesAreInValidLocations.new.as(Rule),
          DirectivesAreUniquePerLocation.new.as(Rule),
          # 5.8 Variables
          VariableUniqueness.new.as(Rule),
          VariablesAreInputTypes.new.as(Rule),
          AllVariableUsesDefined.new.as(Rule),
          AllVariablesUsed.new.as(Rule),
          AllVariableUsagesAreAllowed.new.as(Rule)
        ]
      end
    end
  end
end
