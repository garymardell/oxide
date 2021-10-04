require "http"

module Graphql
  class Query
    include Language::Visitable

    property query_string : String
    property variables : Hash(String, JSON::Any)
    property operation_name : String | Nil

    def initialize(@query_string, @variables = {} of String => JSON::Any, @operation_name = nil)
    end

    def document
      @document ||= begin
        parser = Graphql::Language::Parser.new
        parser.parse(query_string)
      end.as(Graphql::Language::Nodes::Document)
    end

    def accept(visitor : Language::Visitor)
      document.accept(visitor)
    end
  end
end