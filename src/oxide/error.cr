module Oxide
  class Error < Exception
    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "message", message
      end
    end

    def to_h
      { "message" => message }
    end

    def_equals_and_hash @message
  end

  class InputCoercionError < Error
  end

  class InvalidOperationError < Error
  end

  class FieldError < Error
  end

  class NullError < FieldError
  end
end