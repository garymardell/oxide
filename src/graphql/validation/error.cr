module Graphql
  module Validation
    class Error
      property message : String

      def initialize(@message)
      end
    end
  end
end