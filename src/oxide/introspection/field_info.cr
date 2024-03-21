module Oxide
  module Introspection
    struct FieldInfo
      getter name : String
      getter field : Oxide::BaseField

      delegate arguments, type, deprecated?, deprecation_reason, to: field

      def initialize(@name, @field)
      end

      def description
        nil
      end
    end
  end
end