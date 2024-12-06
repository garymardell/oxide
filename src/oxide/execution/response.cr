require "json"

module Oxide
  module Execution
    struct Response
      include JSON::Serializable

      @[JSON::Field(emit_null: true)]
      getter data : SerializedOutput?
      getter errors : Set(RuntimeError)?

      def initialize(@data = nil, @errors = nil)
      end
    end
  end
end