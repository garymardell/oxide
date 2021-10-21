module Graphene
  module Validation
    class Error
      property message : String

      def initialize(@message)
      end

      def_equals @message
    end
  end
end