module Graphql
  module Execution
    class Error
      property message : String?

      def initialize(@message = nil)
      end

      def to_json(builder : JSON::Builder)
        builder.object do
          builder.field "message", message
        end
      end

      def_equals_and_hash @message
    end
  end
end