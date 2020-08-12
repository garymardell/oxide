require "http"

module Graphql
  class Query
    alias Variable = Nil | Bool | Int64 | Float64 | String | Array(Variable) | Hash(String, Variable)
    # alias Variables = String | Int32 | Int64 | Float64 | Bool | Nil | Array(Variables) | Hash(String, Variables)

    property query_string : String
    property variables : Hash(String, JSON::Any::Type)

    def initialize(@query_string, @variables = {} of String => JSON::Any::Type)
    end

    def document
      @document ||= begin
        parser = Graphql::Language::Parser.new
        parser.parse(query_string)
      end.as(Graphql::Language::Nodes::Document)
    end
  end
end