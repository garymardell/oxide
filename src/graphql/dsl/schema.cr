module Graphql
  module DSL
    class Schema
      macro query(object)
        def self.query
          {{object}}
        end
      end

      macro finished
        def self.compile : Graphql::Schema
          Graphql::Schema.new(
            query: self.query.compile
          )
        end

        def self.execute(query_string, variables = {} of String => JSON::Any, operation_name = nil)
          runtime = Graphql::Execution::Runtime.new(
            compile,
            Graphql::Query.new(query_string, variables, operation_name)
          )

          runtime.execute
        end
      end
    end
  end
end