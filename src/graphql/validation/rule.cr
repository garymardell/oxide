require "./error"

module Graphql
  module Validation
    abstract class Rule
      def validate(node)
        [] of Error
      end
    end
  end
end