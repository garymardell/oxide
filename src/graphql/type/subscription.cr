require "../schema/type_resolver"
require "../type"

module Graphql
  class Type
    class Subscription < Object
      getter subscriber : Schema::Subscribable

      def initialize(
        @typename : ::String,
        @resolver : Schema::Resolvable,
        @subscriber : Schema::Subscribable,
        @fields = [] of Schema::Field,
        @implements = [] of Graphql::Type::Interface
      )
        @name = @typename
      end
    end
  end
end