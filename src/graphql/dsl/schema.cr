module Graphql
  module DSL
    class Schema
      macro query(object)
        def self.query
          {{object}}
        end
      end

      macro finished
        def self.compile(context : Graphql::Context = Graphql::NullContext.new) : Graphql::Schema
          Graphql::Schema.new(
            query: self.query.compile(context)
          )
        end

        def self.execute(query_string, context : Graphql::Context = Graphql::NullContext.new, variables = {} of ::String => JSON::Any, operation_name = nil)
          runtime = Graphql::Execution::Runtime.new(
            compile(context),
            Graphql::Query.new(query_string, variables, operation_name)
          )

          runtime.execute
        end
      end
    end
  end
end