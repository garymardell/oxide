require "./rule"
require "./rules/**"
require "../language/visitor"

module Graphql
  module Validation
    class Pipeline < Graphql::Language::Visitor
      property errors : Array(Error)

      private getter rules : Array(Rule)
      private getter schema : Graphql::Schema
      private getter query : Graphql::Query

      def initialize(@schema, @query)
        @errors = [] of Error
        @rules = [
          NoDefinitionIsPresent.new.as(Rule)
        ]
      end

      def visit(node)
        rules.each do |rule|
          @errors += rule.validate(node)
        end
      end

      def execute
        @query.accept(self)
        @errors.any?
      end
    end
  end
end