require "./error"

module Graphql
  module Validation
    abstract class Rule < Graphql::Language::Visitor
      property schema : Graphql::Schema
      property errors : Array(Error)

      def initialize(@schema : Graphql::Schema)
        @errors = [] of Error
      end
    end
  end
end