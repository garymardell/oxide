module Oxide
  struct Response
    include JSON::Serializable

    getter data : SerializedOutput
    getter errors : Set(Error)?

    def initialize(@data, @errors = nil)
    end
  end
end