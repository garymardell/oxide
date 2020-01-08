module Graphql
  class Query
    alias Variable = String | Int32 | Int64 | Float64 | Bool | Nil | Array(Variable) | Hash(String, Variable)

    property query_string : String
    property variables : Variable

    def initialize(@query_string, @variables = nil)
    end

    def document
      @document ||= begin
        parser = Graphql::Language::Parser.new
        parser.parse(query_string)
      end.as(Graphql::Language::Nodes::Document)
    end
  end
end