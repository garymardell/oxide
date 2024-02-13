module Oxide
  module Introspection
    struct ArgumentInfo
      property name : String
      property argument : Oxide::Argument

      delegate description, type, default_value, to: argument

      def initialize(@name, @argument)
      end
    end
  end
end