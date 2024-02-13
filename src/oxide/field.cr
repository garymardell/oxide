require "./argument"

module Oxide
  abstract class BaseField
    abstract def type : Oxide::Type
    abstract def description : String?
    abstract def deprecation_reason : String?
    abstract def arguments : Hash(String, Oxide::Argument)
  end

  class Field(I, O) < BaseField
    getter type : Oxide::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Hash(String, Oxide::Argument)
    setter resolve : Proc(I, O) | Proc(I, ArgumentValues, O) | Proc(I, ArgumentValues, Execution::Context, O) | Proc(I, ArgumentValues, Execution::Context, Execution::ResolutionInfo, O)

    def initialize(@type, @resolve, @description = nil, @deprecation_reason = nil, @arguments = {} of String => Oxide::Argument)
    end

    def resolve(object, argument_values, context, resolution_info)
      if object.is_a?(I)
        resolve_proc = @resolve

        case resolve_proc
        when Proc(I, O)
          resolve_proc.call(object)
        when Proc(I, ArgumentValues, O)
          resolve_proc.call(object, argument_values)
        when Proc(I, ArgumentValues, Execution::Context, O)
          resolve_proc.call(object, argument_values, context)
        when Proc(I, ArgumentValues, Execution::Context, Execution::ResolutionInfo, O)
          resolve_proc.call(object, argument_values, context, resolution_info)
        end
      else
        raise "Calling resolve with incorrect value type, expecting #{I} got #{object.class}"
      end
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
