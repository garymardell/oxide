require "./member"

module Graphql
  class Schema
    class NonNull < Member
      property of_type : Graphql::Schema::Member

      def initialize(@of_type)
      end
    end
  end
end
