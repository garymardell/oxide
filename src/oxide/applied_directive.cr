module Oxide
  class AppliedDirective
    getter name : String

    def initialize(@name : String, @values : Hash(String, CoercedInput) = {} of String => CoercedInput)
    end
  end
end