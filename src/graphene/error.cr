module Graphene
  class Error < Exception
    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "message", message
      end
    end

    def_equals_and_hash @message
  end

  class InputCoercionError < Error
  end
end