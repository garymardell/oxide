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
    getter applied_directives : Array(AppliedDirective)

    @resolve : Proc(I, Resolution, O)

    def initialize(@type, @resolve : Proc(I, Resolution, O), @description = nil, @deprecation_reason = nil, @arguments = {} of String => Oxide::Argument, @applied_directives = [] of AppliedDirective)
    end

    def resolve(object, argument_values, context, resolution_info)
      if object.is_a?(I)
        execution = Resolution.new(
          arguments: argument_values,
          execution_context: context,
          resolution_info: resolution_info
        )

        @resolve.call(object.as(I), execution)
      else
        raise "Invalid type received to resolution"
      end
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
