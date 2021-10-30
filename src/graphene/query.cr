require "http"

module Graphene
  class Query
    include Language::Visitable

    property query_string : String
    property context : Graphene::Context?
    property variables : Hash(String, JSON::Any)
    property operation_name : String | Nil

    def initialize(@query_string, @context = nil, @variables = {} of String => JSON::Any, @operation_name = nil)
    end

    def document
      @document ||= begin
        parser = Graphene::Language::Parser.new
        parser.parse(query_string)
      end.as(Graphene::Language::Nodes::Document)
    end

    def accept(visitor : Language::Visitor)
      document.accept(visitor)
    end
  end
end