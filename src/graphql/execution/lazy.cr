module Graphql
  module Execution
    class Lazy(T)
      property value : T | Nil

      def initialize(&block : -> T)
        @block = block
        @resolved = false
      end

      def value
        if !@resolved
          @resolved = true
          @value = begin
            v = @block.call

            if v.is_a?(Lazy)
              v = v.value
            end

             v
          end
        end

        @value
      end

    end
  end
end