module Graphene
  class Schema
    class IncludeDirective
      def self.include?(directive, variable_values)
        !SkipDirective.skip?(directive, variable_values)
      end
    end
  end
end