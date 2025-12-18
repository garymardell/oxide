require "json"

module Oxide
  module Execution
    struct Response
      include JSON::Serializable

      @[JSON::Field(emit_null: true)]
      getter data : SerializedOutput?
      
      @[JSON::Field(converter: Oxide::Execution::Response::ErrorsConverter)]
      getter errors : Set(RuntimeError)?

      def initialize(@data = nil, @errors = nil)
      end
      
      # Converter to ensure errors are serialized as an array, not a set
      module ErrorsConverter
        def self.to_json(value : Set(RuntimeError)?, builder : JSON::Builder)
          if value.nil?
            builder.null
          else
            builder.array do
              value.each do |error|
                error.to_json(builder)
              end
            end
          end
        end
        
        def self.from_json(parser : JSON::PullParser)
          errors = Set(RuntimeError).new
          parser.read_array do
            # Note: This is just for completeness, we don't typically deserialize responses
            # In practice, errors would need to be reconstructed properly
          end
          errors
        end
      end
    end
  end
end