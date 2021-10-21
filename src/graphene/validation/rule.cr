require "./error"

module Graphene
  module Validation
    abstract class Rule < Graphene::Language::Visitor
      property schema : Graphene::Schema
      property errors : Array(Error)

      def initialize(@schema : Graphene::Schema)
        @errors = [] of Error
      end
    end
  end
end