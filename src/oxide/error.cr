module Oxide
  record Location, line : Int32, column : Int32 do
    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "line", line
        builder.field "column", column
      end
    end

    def to_h
      { "line" => line, "column" => column }
    end

    def_equals_and_hash line, column
  end

  # Base error for all oxide errors to extend from
  class Error < Exception
    getter locations : Array(Location) = [] of Location
    getter path : Array(String | Int32)? = nil

    def initialize(message, @locations = [] of Location, @path = nil)
      super(message)
    end

    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "message", message
        
        if locations.any?
          builder.field "locations" do
            builder.array do
              locations.each do |location|
                location.to_json(builder)
              end
            end
          end
        end
        
        if p = @path
          builder.field "path" do
            builder.array do
              p.each do |segment|
                segment.to_json(builder)
              end
            end
          end
        end
      end
    end

    def to_h
      result = { "message" => message } of String => (String | Array(Hash(String, Int32)) | Array(String | Int32))
      
      if locations.any?
        result["locations"] = locations.map(&.to_h)
      end
      
      if p = @path
        result["path"] = p
      end
      
      result
    end

    def_equals_and_hash @message, @locations, @path
  end

  class CombinedError < Exception
    getter errors : Array(Error)

    def initialize(@errors : Array(Error))
    end

    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "errors" do
          errors.each do |error|
            error.to_json(builder)
          end
        end
      end
    end
  end

  # When there is an issue with the schema such as incorrecy resolver types
  class SchemaError < Error
  end

  # When there is an issue lexing / parsing the query
  class ParseError < Error
  end

  # Base for all issues that occur during runtime to provide accurate location responses
  class RuntimeError < Error
  end

  class ValidationError < RuntimeError
  end

  class FieldError < RuntimeError
  end

  class InputCoercionError < RuntimeError
  end

  class SerializationError < RuntimeError
  end
end